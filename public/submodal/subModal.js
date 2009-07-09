/**
 * SUBMODAL v1.5
 * Used for displaying DHTML only popups instead of using buggy modal windows.
 *
 * By Seth Banks (webmaster at subimage dot com)
 * http://www.subimage.com/
 *
 * Contributions by:
 *  Eric Angel - tab index code
 *  Scott - hiding/showing selects for IE users
 *  Todd Huss - inserting modal dynamically and anchor classes
 *
 * Up to date code can be found at http://www.subimage.com/dhtml/subModal
 * 
 *
 * This code is free for you to use anywhere, just keep this comment block.
 */

RTVModal = {
  gPopupIsShown: false,
  gPopupMask: null,
  gPopupContainer: null,
  gPopFrame: null,
  gReturnFunc: null,
  
  gDefaultPage: "http://localhost:3000/submodal/loading.html",
  gHideSelects: false,
  gReturnVal: null,
  // We can set this from within the modal to ALWAYS call the return function,
  // even from the close box.
  gCallReturnFunc: false,
  
  gTabIndexes: new Array(),
  // Pre-defined list of tags we want to disable/enable tabbing into
  gTabbableTags: new Array("A","BUTTON","TEXTAREA","INPUT","IFRAME")  
};

/**
 * COMMON DHTML FUNCTIONS
 * These are handy functions I use all the time.
 *
 * By Seth Banks (webmaster at subimage dot com)
 * http://www.subimage.com/
 *
 * Up to date code can be found at http://www.subimage.com/dhtml/
 *
 * This code is free for you to use anywhere, just keep this comment block.
 */

/**
 * X-browser event handler attachment and detachment
 * TH: Switched first true to false per http://www.onlinetools.org/articles/unobtrusivejavascript/chapter4.html
 *
 * @argument obj - the object to attach event to
 * @argument evType - name of the event - DONT ADD "on", pass only "mouseover", etc
 * @argument fn - function to call
 */

RTVModal.addEvent = function(obj, evType, fn){
 if (obj.addEventListener){
    obj.addEventListener(evType, fn, false);
    return true;
 } else if (obj.attachEvent){
    var r = obj.attachEvent("on"+evType, fn);
    return r;
 } else {
    return false;
 }
}
// function removeEvent(obj, evType, fn, useCapture){
//   if (obj.removeEventListener){
//     obj.removeEventListener(evType, fn, useCapture);
//     return true;
//   } else if (obj.detachEvent){
//     var r = obj.detachEvent("on"+evType, fn);
//     return r;
//   } else {
//     alert("Handler could not be removed");
//   }
// }

/**
 * Code below taken from - http://www.evolt.org/article/document_body_doctype_switching_and_more/17/30655/
 *
 * Modified 4/22/04 to work with Opera/Moz (by webmaster at subimage dot com)
 *
 * Gets the full width/height because it's different for most browsers.
 */
RTVModal.getViewportHeight = function() {
	if (window.innerHeight!=window.undefined) return window.innerHeight;
	if (document.compatMode=='CSS1Compat') return document.documentElement.clientHeight;
	if (document.body) return document.body.clientHeight; 

	return window.undefined; 
}
RTVModal.getViewportWidth = function() {
	var offset = 17;
	var width = null;
	if (window.innerWidth!=window.undefined) return window.innerWidth; 
	if (document.compatMode=='CSS1Compat') return document.documentElement.clientWidth; 
	if (document.body) return document.body.clientWidth; 
}

/**
 * Gets the real scroll top
 */
// RTVModal.getScrollTop = function() {
//  if (self.pageYOffset) // all except Explorer
//  {
//    return self.pageYOffset;
//  }
//  else if (document.documentElement && document.documentElement.scrollTop)
//    // Explorer 6 Strict
//  {
//    return document.documentElement.scrollTop;
//  }
//  else if (document.body) // all other Explorers
//  {
//    return document.body.scrollTop;
//  }
// }
// RTVModal.getScrollLeft = function() {
//  if (self.pageXOffset) // all except Explorer
//  {
//    return self.pageXOffset;
//  }
//  else if (document.documentElement && document.documentElement.scrollLeft)
//    // Explorer 6 Strict
//  {
//    return document.documentElement.scrollLeft;
//  }
//  else if (document.body) // all other Explorers
//  {
//    return document.body.scrollLeft;
//  }
// }

// end common.js

// Popup code

// If using Mozilla or Firefox, use Tab-key trap.
if (!document.all) {
  document.onkeypress = RTVModal.keyDownHandler;
}

/**
 * Initializes popup code on load.  
 */
RTVModal.initPopUp = function() {
  // Add the HTML to the body
  theBody = document.getElementsByTagName('BODY')[0];
  popmask = document.createElement('div');
  popmask.id = 'popupMask';
  popcont = document.createElement('div');
  popcont.id = 'popupContainer';
  popcont.innerHTML = '' +
    '<div id="popupInner">' +
      '<div id="popupTitleBar">' +
        '<div id="popupTitle"></div>' +
        '<div id="popupControls">' +
          '<img src="http://localhost:3000/submodal/close.gif" onclick="RTVModal.hidePopWin(false);" id="popCloseBox" />' +
        '</div>' +
      '</div>' +
      '<iframe src="'+ RTVModal.gDefaultPage +'" style="width:100%;height:100%;background-color:transparent;" scrolling="auto" frameborder="0" allowtransparency="true" id="popupFrame" name="popupFrame" width="100%" height="100%"></iframe>' +
    '</div>';
  theBody.appendChild(popmask);
  theBody.appendChild(popcont);
  // RTVModal.addEvent(popmask, "click", RTVModal.hidePopWin);
  
  RTVModal.gPopupMask = document.getElementById("popupMask");
  RTVModal.gPopupContainer = document.getElementById("popupContainer");
  RTVModal.gPopFrame = document.getElementById("popupFrame");  
  
  // check to see if this is IE version 6 or lower. hide select boxes if so
  // maybe they'll fix this in version 7?
  var brsVersion = parseInt(window.navigator.appVersion.charAt(0), 10);
  if (brsVersion <= 6 && window.navigator.userAgent.indexOf("MSIE") > -1) {
    RTVModal.gHideSelects = true;
  }
  
  // Add onclick handlers to 'a' elements of class submodal or submodal-width-height
  // var elms = document.getElementsByTagName('a');
  // for (i = 0; i < elms.length; i++) {
  //   if (elms[i].className.indexOf("submodal") == 0) { 
  //     // var onclick = 'function (){RTVModal.showPopWin(\''+elms[i].href+'\','+width+', '+height+', null);return false;};';
  //     // elms[i].onclick = eval(onclick);
  //     elms[i].onclick = function(){
  //       // default width and height
  //       var width = 400;
  //       var height = 200;
  //       // Parse out optional width and height from className
  //       params = this.className.split('-');
  //     if (params.length == 3) {
  //         width = parseInt(params[1]);
  //         height = parseInt(params[2]);
  //       }
  //       RTVModal.showPopWin(this.href,width,height,null); return false;
  //     }
  //   }
  // }
}
RTVModal.addEvent(window, "load", RTVModal.initPopUp);

 /**
  * @argument width - int in pixels
  * @argument height - int in pixels
  * @argument url - url to display
  * @argument returnFunc - function to call when returning true from the window.
  * @argument showCloseBox - show the close box - default true
  */

RTVModal.showPopWin = function(url, width, height, returnFunc, showCloseBox) {
  // show or hide the window close widget
  if (showCloseBox == null || showCloseBox == true) {
    document.getElementById("popCloseBox").style.display = "block";
  } else {
    document.getElementById("popCloseBox").style.display = "none";
  }
  RTVModal.gPopupIsShown = true;
  RTVModal.disableTabIndexes();
  RTVModal.gPopupMask.style.display = "block";
  RTVModal.gPopupContainer.style.display = "block";
  // calculate where to place the window on screen
  RTVModal.centerPopWin(width, height);
  
  var titleBarHeight = parseInt(document.getElementById("popupTitleBar").offsetHeight, 10);

  RTVModal.gPopupContainer.style.width = width + "px";
  RTVModal.gPopupContainer.style.height = (height+titleBarHeight) + "px";
  
  RTVModal.setMaskSize();

  // need to set the width of the iframe to the title bar width because of the dropshadow
  // some oddness was occuring and causing the frame to poke outside the border in IE6
  RTVModal.gPopFrame.style.width = parseInt(document.getElementById("popupTitleBar").offsetWidth, 10) + "px";
  RTVModal.gPopFrame.style.height = (height) + "px";
  
  // set the url
  RTVModal.gPopFrame.src = url;
  
  RTVModal.gReturnFunc = returnFunc;
  // for IE
  if (RTVModal.gHideSelects == true) {
    RTVModal.hideSelectBoxes();
  }
  
  window.setTimeout("RTVModal.setPopTitle();", 600);
}

//
// var gi = 0;
RTVModal.centerPopWin = function(width, height) {
  if (RTVModal.gPopupIsShown == true) {
    if (width == null || isNaN(width)) {
      width = RTVModal.gPopupContainer.offsetWidth;
    }
    if (height == null) {
      height = RTVModal.gPopupContainer.offsetHeight;
    }

    var theBody = document.getElementsByTagName("BODY")[0];
    theBody.width = Math.max(theBody.width, width);
    theBody.height = Math.max(theBody.height, height);

    RTVModal.setMaskSize();

    //window.status = RTVModal.gPopupMask.style.top + " " + RTVModal.gPopupMask.style.left + " " + gi++;

    var titleBarHeight = parseInt(document.getElementById("popupTitleBar").offsetHeight, 10);

    var fullHeight = RTVModal.getViewportHeight();
    var fullWidth = RTVModal.getViewportWidth();

    RTVModal.gPopupContainer.style.top = Math.max((((fullHeight - (height+titleBarHeight)) / 2)), 0) + "px";
    RTVModal.gPopupContainer.style.left =  Math.max((((fullWidth - width) / 2)), 0) + "px";
    //alert(fullWidth + " " + width + " " + RTVModal.gPopupContainer.style.left);
  }
}
RTVModal.addEvent(window, "resize", RTVModal.centerPopWin);

/**
 * Sets the size of the popup mask.
 *
 */
RTVModal.setMaskSize = function() {
  var theBody = document.getElementsByTagName("BODY")[0];

  var fullHeight = RTVModal.getViewportHeight();
  var fullWidth = RTVModal.getViewportWidth();

  popHeight = Math.max(fullHeight, theBody.scrollHeight);
  popWidth = Math.max(fullWidth, theBody.scrollWidth);

  RTVModal.gPopupMask.style.height = popHeight + "px";
  RTVModal.gPopupMask.style.width = popWidth + "px";
}

/**
 * @argument callReturnFunc - bool - determines if we call the return function specified
 * @argument returnVal - anything - return value 
 */
RTVModal.hidePopWin = function(callReturnFunc) {
  RTVModal.gPopupIsShown = false;
  var theBody = document.getElementsByTagName("BODY")[0];
  theBody.style.overflow = "";
  RTVModal.restoreTabIndexes();
  if (RTVModal.gPopupMask == null) {
    return;
  }
  RTVModal.gPopupMask.style.display = "none";
  RTVModal.gPopupContainer.style.display = "none";
  if ((callReturnFunc == true || RTVModal.gCallReturnFunc == true) && RTVModal.gReturnFunc != null) {
    // Set the return code to run in a timeout.
    // Was having issues using with an Ajax.Request();
    RTVModal.gReturnVal = window.frames["popupFrame"].returnVal;
    window.setTimeout('RTVModal.gReturnFunc(RTVModal.gReturnVal);', 1);
    // Reset global return function boolean.
    RTVModal.gCallReturnFunc = false;
  }
  RTVModal.gPopFrame.src = RTVModal.gDefaultPage;
  // display all select boxes
  if (RTVModal.gHideSelects == true) {
    RTVModal.displaySelectBoxes();
  }
}

/**
 * Sets the popup title based on the title of the html document it contains.
 * Uses a timeout to keep checking until the title is valid.
 */
RTVModal.setPopTitle = function() {
  return;
  if (window.frames["popupFrame"].document.title == null) {
    window.setTimeout("RTVModal.setPopTitle();", 10);
  } else {
    document.getElementById("popupTitle").innerHTML = window.frames["popupFrame"].document.title;
  }
}

// Tab key trap. iff popup is shown and key was [TAB], suppress it.
// @argument e - event - keyboard event that caused this function to be called.
RTVModal.keyDownHandler = function(e) {
  if (RTVModal.gPopupIsShown && e.keyCode == 9)  return false;
}

// For IE.  Go through predefined tags and disable tabbing into them.
RTVModal.disableTabIndexes = function() {
  if (document.all) {
    var i = 0;
    for (var j = 0; j < RTVModal.gTabbableTags.length; j++) {
      var tagElements = document.getElementsByTagName(RTVModal.gTabbableTags[j]);
      for (var k = 0 ; k < tagElements.length; k++) {
        RTVModal.gTabIndexes[i] = tagElements[k].tabIndex;
        tagElements[k].tabIndex="-1";
        i++;
      }
    }
  }
}

// For IE. Restore tab-indexes.
RTVModal.restoreTabIndexes = function() {
  if (document.all) {
    var i = 0;
    for (var j = 0; j < RTVModal.gTabbableTags.length; j++) {
      var tagElements = document.getElementsByTagName(RTVModal.gTabbableTags[j]);
      for (var k = 0 ; k < tagElements.length; k++) {
        tagElements[k].tabIndex = RTVModal.gTabIndexes[i];
        tagElements[k].tabEnabled = true;
        i++;
      }
    }
  }
}

/**
* Hides all drop down form select boxes on the screen so they do not appear above the mask layer.
* IE has a problem with wanted select form tags to always be the topmost z-index or layer
*
* Thanks for the code Scott!
*/
RTVModal.hideSelectBoxes = function() {
  for(var i = 0; i < document.forms.length; i++) {
    for(var e = 0; e < document.forms[i].length; e++){
      if(document.forms[i].elements[e].tagName == "SELECT") {
        document.forms[i].elements[e].style.visibility="hidden";
      }
    }
  }
}

/**
* Makes all drop down form select boxes on the screen visible so they do not reappear after the dialog is closed.
* IE has a problem with wanted select form tags to always be the topmost z-index or layer
*/
RTVModal.displaySelectBoxes = function() {
  for(var i = 0; i < document.forms.length; i++) {
    for(var e = 0; e < document.forms[i].length; e++){
      if(document.forms[i].elements[e].tagName == "SELECT") {
      document.forms[i].elements[e].style.visibility="visible";
      }
    }
  }
}