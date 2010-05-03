var maps_containers = [];
var allMarkers = {};
var relatedMarkers = {};
var allMaps = {};
var dragging = false;


$(document).ready(function() {
	// enable edit in place triggers
	$('.trigger').addClass('visible');
	
	$('.delete').live("click",function() {
		if (confirm('Oh yeah?'))
			//$.post(this.href, { _method: 'delete' }, null, "script");
	    	$.ajax({url: $(this).attr('href'), type: "POST", data: ({ _method: 'delete' }), dataType: 'script'});
	    return false;
	  });
	
	// enable ajax post requests 
	$('a.post').click(function() {
		selectPost($(this));
		return false;
	});
	
	// show the first two available maps.
	// This should be done last!
	for (var i=0; i<2 && i<maps_containers.length; i++)
		showMap(maps_containers[0], maps_containers[1]);
});

function selectPost(postLink) {
	// turn off the currently selected link and marker
	selectedPost = postLink.siblings('.selected');
	if (selectedPost.length > 0) {
		selectedPost.removeClass('selected');
		
		var oldMarker = allMarkers[selectedPost[0].id];
		if (oldMarker) {
			oldMarker.isSelected = false;
			oldMarker.setImage(oldMarker.iconDefault);
		}
	}
	
	// turn on the new link and marker
	postLink.addClass('selected');
	var newMarker = allMarkers[$(postLink).attr('id')];
	if (newMarker) {
		newMarker.isSelected = true;
		newMarker.setImage(newMarker.iconSelected);
	}
		
	// update the page
	$.ajax({url: postLink.attr('href'), dataType: 'script'});
}

/**
 * Listener function for map markers.
 * Highlights the thumbnail, swaps the marker icon to the "active" image, and moves the icon to the front of the stack.
 */
function markerMouseOver(postId, groupId, fromLink) {
	if (dragging) return;
	
	var marker = allMarkers['post' + postId + '_group' + groupId];
	if (marker.isAdding) {
		marker.isAdding = false;
	}
	
	if (marker.isActive) return;
	
	// highlight the thumbnail
	$('a#post' + postId + '_group' + groupId).addClass('active');
	
	marker.isActive = true;
	
	// move the marker to the top of the stack
	var map = allMaps[marker.mapId];
	map.removeOverlay(marker);
	
	if (!fromLink) {
		marker.isAdding = true;
		setTimeout("forceMouseOut('" + postId + "', '" + groupId + "')",100);
	}
	
	// show the "active" marker
	map.addOverlay(marker);
	marker.setImage(marker.iconActive);
}

function forceMouseOut(postId, groupId) {
	var marker = allMarkers['post' + postId + '_group' + groupId];;
	if (marker.isAdding) {
		markerMouseOut(postId, groupId);
	}
}

/**
 * Listener function for mousing out a thumbnail or map marker within a Post group.
 * Unhighlights the thumbnail and swaps the marker icon to the "default" image.
 */
function markerMouseOut(postId, groupId, fromLink) {
	if (dragging) return;
	
	var marker = allMarkers['post' + postId + '_group' + groupId];;
	var map = allMaps[marker.mapId];
	
	// unhighlight the thumbnail
	$('a#post' + postId + '_group' + groupId).removeClass('active');
	
	// move the marker to the top of the stack
	marker.isActive = false;
	marker.isAdding = false;
	
	// show the "default" marker
	if (marker.isSelected)
		marker.setImage(marker.iconSelected);
	else
		marker.setImage(marker.iconDefault);
}

function markerClick(postId, groupId) {
	selectPost($('#post' + postId + '_group' + groupId));
	return false;
}

function markerDragStart(postId, groupId) {
	dragging = true;
}

function markerDrag(postId, groupId) {
	if (postId == 'new') {
		var latLng = allMarkers['post' + postId + '_group' + groupId].getLatLng();
		$('#new_post input.latitude').val(latlng.lat());
		$('#new_post input.longitude').val(latlng.lng());
	}
}

function markerDragEnd(postId, groupId, latlng) {
	dragging = false;
	
	if (postId == 'new') {
		$('#new_post input.latitude').val(latlng.lat());
		$('#new_post input.longitude').val(latlng.lng());

	    var current_date = new Date( );
	    var gmt_offset = current_date.getTimezoneOffset( ) / 60;
		var gmt_offset_string = (gmt_offset<0?"":"-") + ((gmt_offset<10)?"0":"")+Math.abs(gmt_offset)+"00";
		
		var time_at = $('#new_post select#post_time_at_1i').val() 
					+ "/" + $('#new_post select#post_time_at_2i').val()
					+ "/" + $('#new_post select#post_time_at_3i').val()
					+ " " + $('#new_post select#post_time_at_4i').val()
					+ ":" + $('#new_post select#post_time_at_5i').val()
					+ " " + gmt_offset_string
					;
		
		$.post("./suggested.html"
			,
			{ 
				//"post[latitude]": latlng.lat(), "post[longitude]": latlng.lng(), 
				"metrics_manager[latitude]": latlng.lat(), 
				"metrics_manager[longitude]": latlng.lng(), 
				"metrics_manager[time_at]": time_at, 
				"metrics_manager[limit]": 3, 
				"metrics_manager[boxed]": 1, 
				"_method": "post" 
			}
			,
			function(data)
			{
				$('#suggested-results').html(data)
			}
		);
		
	} else {
		$.post("/posts/" + postId + ".js",
			{ "post[latitude]": latlng.lat(), "post[longitude]": latlng.lng(), "_method": "put" },
			function(data){
				//eval(data); 
			}
		);
	}
}

/**
 * Given a map ID and array of marker objects (as generated by application_helper.create_post_map_marker)
 * Creates a GMap populated and centered on GMarkers using the JSON data within the marker objects,
 * Adds mouse and click events to map markers and any corresponding thumbnail links within a group,
 * And displays the map.
 * 
 * Used for both group map display and new post form map display.
 */
function showMap(mapId, markerObjects) {
	if (!GBrowserIsCompatible() || markerObjects.length == 0)
		return;
	
	// create the map and add to the all maps data object for later reference from map point events
	map = new GMap2(document.getElementById(mapId));
	map.setCenter(new GLatLng(37.7517,-122.425),7);
	map.setMapType(G_HYBRID_MAP);
	allMaps[mapId] = map;
	
	// array of points contained within the map, used for center-and-zooming after creation
	var points = [];
	
	// find the currently selected post, if any
	var selected_post = $('div#social_set' + markerObjects[0].group_id + ' div.photos div.thumbs a.selected').attr('id');
	
	// loop through the marker objects
	for (var i = 0; i < markerObjects.length; i++) {
		var mrkrObject = markerObjects[i];
		if (mrkrObject == undefined) continue;
		
		// Assign the marker images for default, active (rolled over) and selected (currently viewing)
		var iconBase = "/images/map_marker";
		iconBase += mrkrObject.marker_type ? "_" + mrkrObject.marker_type : ""
		var iconDefault = iconBase + "_default.png";
		var iconActive = iconBase + "_active.png";
		var iconSelected = iconBase + "_selected.png";
		
		//if this is the selected post, display the selected icon
		var iconCurrent = 'post' + mrkrObject.post_id + '_social_set' + mrkrObject.group_id == selected_post ? iconSelected : iconDefault;
		
		//create the gmarker object
		var marker = new GMarker(
			new GLatLng(mrkrObject.lat, mrkrObject.lng),
			{
				icon : addOptionsToIcon(new GIcon(),{
					iconSize : new GSize(24,24),
					image : iconCurrent,
					iconAnchor : new GPoint(12,12)
					}
				),
				draggable :mrkrObject.draggable,
				zIndexProcess : getMarkerZIndex // adds z-index swapping functionality
			}
		);
		
		// assign relevant data about the marker and related map / group / post
		marker.mapId = mapId;
		marker.postId = mrkrObject.post_id;
		marker.groupId = mrkrObject.group_id;
		marker.naturalGroupId = mrkrObject.natural_group_id;
		marker.iconDefault = iconDefault;
		marker.iconActive = iconActive;
		marker.iconSelected = iconSelected;
		marker.isSelected = i == 0;
		
		marker.isDraggable = mrkrObject.draggable;
		//marker.isCenter = (mrkrObject.marker_type == "center");
		marker.isCenter = (mrkrObject.marker_type == "ss_center") || (mrkrObject.marker_type == "ps_center");
		marker.isNew = (mrkrObject.post_id == "new");


		
		//create the bounding-box for centers
		if (marker.isCenter)
		{
			var lat = parseFloat(mrkrObject.cx);
			var lon = parseFloat(mrkrObject.cy);
			//var latOffset = 0.01;
			//var lonOffset = 0.01;
			var latOffset = parseFloat(mrkrObject.wx);
			var lonOffset = parseFloat(mrkrObject.wy);
			var bgcolor = (mrkrObject.marker_type == "ps_center")?"#ff0000":"#0000ff";
			var bgalpha = (mrkrObject.marker_type == "ps_center")?0.2:0.1;
			var lncolor = (mrkrObject.marker_type == "ps_center")?"#f33f00":"#003ff3";
			var lnthickness = (mrkrObject.marker_type == "ps_center")?1:2;
			var lnalpha = (mrkrObject.marker_type == "ps_center")?1:1;
			var polygon = new GPolygon([
				new GLatLng(lat +latOffset, lon -lonOffset),
				new GLatLng(lat +latOffset, lon +lonOffset),
				new GLatLng(lat -latOffset, lon +lonOffset),
				new GLatLng(lat -latOffset, lon -lonOffset),
				new GLatLng(lat +latOffset, lon -lonOffset)
			], lncolor, lnthickness, lnalpha, bgcolor, bgalpha);
			map.addOverlay(polygon);

		}

		
		// add to the map and insert point data
		map.addOverlay(marker);
		points.push(marker.getPoint());
		
		// assign event listeners
		
		if (!marker.isCenter)
		{
			GEvent.addListener(marker,"mouseover",function(latlng){ markerMouseOver(this.postId, this.groupId); });
			GEvent.addListener(marker,"click",function(latlng){ markerClick(this.postId, this.groupId); });
			GEvent.addListener(marker,"mouseout",function(latlng){ markerMouseOut(this.postId, this.groupId); });
		}
		
		if (marker.isDraggable)
		{
			GEvent.addListener(marker,"dragstart",function(latlng){ markerDragStart(this.postId, this.groupId); });
			GEvent.addListener(marker,"dragend",function(latlng){ markerDragEnd(this.postId, this.groupId, latlng); });
		}
		
		// assign event listeners for any thumbnail images that need to interact with the map
		$('a#post' + marker.postId + '_group' + marker.groupId).mouseover(function(){
			var postId = String(new RegExp(/post[0-9]+/).exec(String(this.id))).substr(4);
			var groupId = String(new RegExp(/group[0-9]+/).exec(String(this.id))).substr(5);
			markerMouseOver(postId, groupId, true);
		});
		$('a#post' + marker.postId + '_group' + marker.groupId).mouseout(function(){
			var postId = String(new RegExp(/post[0-9]+/).exec(String(this.id))).substr(4);
			var groupId = String(new RegExp(/group[0-9]+/).exec(String(this.id))).substr(5);
			markerMouseOut(postId, groupId, true);
		});
		
		// push the item into the all
		if (allMarkers) {
			allMarkers['post' + marker.postId + '_group' + marker.groupId] = marker;
			
			if (marker.groupId != marker.naturalGroupId) {
				if (relatedMarkers[marker.groupId + "_" + marker.naturalGroupId] == undefined) {
					relatedMarkers[marker.groupId + "_" + marker.naturalGroupId] = [];
				}
				relatedMarkers[marker.groupId + "_" + marker.naturalGroupId].push(marker);
			}
		}
	}
	
	// bump the selected marker to the top z-index in the map
	if (selected_post)		
	{
		var selectedMarker = allMarkers[selected_post];
		map.removeOverlay(selectedMarker);
		selectedMarker.isActive = true;
		map.addOverlay(selectedMarker);
		selectedMarker.isActive = false;
	}
	
	// center and zoom the map
	map.centerAndZoomOnPoints(points);
	map.addControl(new GSmallMapControl());
}

function toggleRelatedMarkers(markers_group_id, show) {
	var markers_group = relatedMarkers[markers_group_id];
	
	if (markers_group == undefined)
		return;
	
	for (var i=0; i < markers_group.length; i++) {
		var marker = markers_group[i];
		if (show) {
			marker.show();
			$('#post' + marker.postId + '_group' + marker.groupId).fadeIn();
		} else {
			marker.hide();
			$('#post' + marker.postId + '_group' + marker.groupId).fadeOut();
		}
	}
}

/**
 * z-index swapping implementation for GMarker items
 */
function getMarkerZIndex(marker,b) {
	if (marker.isActive) return 100000;
	if (marker.isNew) return 100000;

	return GOverlay.getZIndex(marker.getPoint().lat());
}