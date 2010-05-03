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
  var children = obj.getChildNodes();
  for(var i = 0; i < children.length; i++) {
    var child = children[i];
    if(matches_selector(child, selector)) {
      callback(child);
    }
    foreach(child, selector, callback);
  }
}
