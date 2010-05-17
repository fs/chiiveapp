var ajax = null;

function matches_selector(obj, selector) {
  if(selector[0] == '.') {
    return obj.hasClassName(selector.substring(1));
  } else if(selector[0] == '#') {
    return obj.getId() == selector.substring(1);
  } else {
    return obj.getTagName() == selector.toUpperCase();
  }
}

function foreach(obj, selector, callback) {
  if(!obj) return;
  var children = obj.getChildNodes();
  for(var i = 0; i < children.length; i++) {
    var child = children[i];
    if(matches_selector(child, selector)) {
      callback(child);
    }
    foreach(child, selector, callback);
  }
}

function ajaxify_link(e, target_id, loader_id) {
  e.addEventListener('click', function() {
    if(ajax != null) {
      ajax.abort();
    }
    
    if(typeof(loader_id) == 'undefined') {
      loader_id = 'ajaxloader';
    }
    
    if(loader_id != false) {
      var loader = document.getElementById(loader_id);
      var container = document.getElementById(target_id);
      loader.setStyle('height', container.getClientHeight() + 'px');
      Animation(loader).to('opacity', 0.8).from(0).show().go();
    }
    
    ajax = new Ajax();
    ajax.responseType = Ajax.FBML;
    ajax.ondone = function(data) {
      container.setInnerFBML(data);
      if(loader_id != false) {
        Animation(loader).hide().to('opacity', 0).from(0.8).go();
      }
    };
    ajax.onerror = function() {};
    
    var url = e.getHref().replace(new RegExp("http://apps.facebook.com\/[^\/]*"), "");
    url = "http://" + request_host + url;
    ajax.requireLogin = 1;
    ajax.post(url, {'_method' : 'GET'});
    
    return false;
  });
}
