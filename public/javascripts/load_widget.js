if ((parent == window) && (/WebKit\/[4-7]|MSIE [6-9]|Gecko\/200(51[12]|[6-9])|Opera\/9/.test(navigator.userAgent))) {
  var rtvCss = document.createElement('link');
  rtvCss.href = 'http://localhost:3000/submodal/subModal.css';
  rtvCss.rel = "stylesheet";
  rtvCss.type = "text/css";
  var rtvJs = document.createElement('script');
  rtvJs.src = 'http://localhost:3000/submodal/subModal.js';
  rtvJs.type = "text/javascript";

  // TODO: is setTimeout the way to go?
  setTimeout(function () {
    document.body.appendChild(rtvCss);
    document.body.appendChild(rtvJs);
  },0);

  function rtvShowOverlay(e) {
    RTVModal.initPopUp('http://localhost:3000');
    RTVModal.showPopWin('/registrants/new', 600, 500, null);
    e = e || event
    e.preventDefault ? e.preventDefault() : e.returnValue = false;
  }

  var rtvWidgetLink = document.getElementById('rtv-widget-link');
  if (rtvWidgetLink.addEventListener){
    rtvWidgetLink.addEventListener('click', rtvShowOverlay, false);
  } else if (rtvWidgetLink.attachEvent){
    rtvWidgetLink.attachEvent("onclick", rtvShowOverlay);
  }
}
