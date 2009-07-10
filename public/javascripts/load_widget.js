var rtvWidgetLink = document.getElementById('rtv-widget-link');
if (rtvWidgetLink != null) {
  var rtvCss = document.createElement('link');
  rtvCss.href = 'http://localhost:3000/submodal/subModal.css';
  rtvCss.rel = "stylesheet";
  rtvCss.type = "text/css";
  var rtvJs = document.createElement('script');
  rtvJs.src = 'http://localhost:3000/submodal/subModal.js';
  rtvJs.type = "text/javascript";

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

  if (rtvWidgetLink.addEventListener){
    rtvWidgetLink.addEventListener('click', rtvShowOverlay, false);
  } else if (rtvWidgetLink.attachEvent){
    rtvWidgetLink.attachEvent("onclick", rtvShowOverlay);
  }
}