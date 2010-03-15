/*********************************************************************************
* Floatbox v3.54.3
* November 29, 2009
*
* Copyright (c) 2008-2009 Byron McGregor
* Website: http://randomous.com/floatbox
* License: Attribution-Noncommercial-No Derivative Works 3.0 Unported
*          http://creativecommons.org/licenses/by-nc-nd/3.0/
* Use on any commercial site requires registration and purchase of a license key.
* See http://randomous.com/floatbox/license for details.
* This comment block must be retained in all deployments and distributions.
*********************************************************************************/

function Floatbox() {
this.defaultOptions = {

/***** BEGIN OPTIONS CONFIGURATION *****/
// See docs/options.html for detailed descriptions.
// All options can be overridden with rev/data-fb-options tag or page options (see docs/instructions.html).

/*** <General Options> ***/
licenseKey:       ''        ,// you can paste your license key here instead of in licenseKey.js if you want
padding:           24       ,// pixels
panelPadding:      8        ,// pixels
overlayOpacity:    55       ,// 0-100
shadowType:       'drop'    ,// 'drop'|'halo'|'none'
shadowSize:        12       ,// 8|12|16|24
roundCorners:     'all'     ,// 'all'|'top'|'none'
cornerRadius:      12       ,// 8|12|20
roundBorder:       1        ,// 0|1
outerBorder:       4        ,// pixels
innerBorder:       1        ,// pixels
autoFitImages:     true     ,// true|false
resizeImages:      true     ,// true|false
autoFitOther:      false    ,// true|false
resizeOther:       false    ,// true|false
resizeTool:       'cursor'  ,// 'cursor'|'topleft'|'both'
captionPos:       'bl'      ,// 'tl'|'tc'|'tr'|'bl'|'bc'|'br'
caption2Pos:      'tc'      ,// 'tl'|'tc'|'tr'|'bl'|'bc'|'br'
infoLinkPos:      'bl'      ,// 'tl'|'tc'|'tr'|'bl'|'bc'|'br'
printLinkPos:     'bl'      ,// 'tl'|'tc'|'tr'|'bl'|'bc'|'br'
newWindowLinkPos: 'tr'      ,// 'tl'|'tc'|'tr'|'bl'|'bc'|'br'
itemNumberPos:    'bl'      ,// 'tl'|'tc'|'tr'|'bl'|'bc'|'br'
indexLinksPos:    'br'      ,// 'tl'|'tc'|'tr'|'bl'|'bc'|'br'
controlsPos:      'br'      ,// 'tl'|'tr'|'bl'|'br'
centerNav:         false    ,// true|false
colorImages:      'black'   ,// 'black'|'white'|'blue'|'yellow'|'red'|'custom'
colorHTML:        'white'   ,// 'black'|'white'|'blue'|'yellow'|'red'|'custom'
colorVideo:       'blue'    ,// 'black'|'white'|'blue'|'yellow'|'red'|'custom'
boxLeft:          'auto'    ,// 'auto'|pixels|'[-]xx%'
boxTop:           'auto'    ,// 'auto'|pixels|'[-]xx%'
enableDragMove:    false    ,// true|false
stickyDragMove:    true     ,// true|false
enableDragResize:  false    ,// true|false
stickyDragResize:  true     ,// true|false
draggerLocation:  'frame'   ,// 'frame'|'content'
minContentWidth:   140      ,// pixels
minContentHeight:  100      ,// pixels
centerOnResize:    true     ,// true|false
titleAsCaption:    true     ,// true|false
showItemNumber:    true     ,// true|false
showClose:         true     ,// true|false
showNewWindowIcon: true     ,// true|false
closeOnNewWindow:  false    ,// true|false
cacheAjaxContent:  false    ,// true|false
hideObjects:       true     ,// true|false
hideJava:          true     ,// true|false
disableScroll:     false    ,// true|false
randomOrder:       false    ,// true|false
printCSS:         ''        ,// path to css file or inline css string to apply to print pages (see showPrint)
preloadAll:        true     ,// true|false
autoGallery:       false    ,// true|false
autoTitle:        ''        ,// common caption string to use with autoGallery
language:         'auto'    ,// 'auto'|'en'|... (see the languages folder)
graphicsType:     'auto'    ,// 'auto'|'international'|'english'
/*** </General Options> ***/

/*** <Animation Options> ***/
doAnimations:         true   ,// true|false
resizeDuration:       3.5    ,// 0-10
imageFadeDuration:    3      ,// 0-10
overlayFadeDuration:  4      ,// 0-10
startAtClick:         true   ,// true|false
zoomImageStart:       true   ,// true|false
liveImageResize:      true   ,// true|false
splitResize:         'no'    ,// 'no'|'auto'|'wh'|'hw'
cycleInterval:        5      ,// seconds
cycleFadeDuration:    4.5    ,// 0-10
/*** </Animation Options> ***/

/*** <Navigation Options> ***/
navType:            'both'    ,// 'overlay'|'button'|'both'|'none'
navOverlayWidth:     35       ,// 0-50
navOverlayPos:       30       ,// 0-100
showNavOverlay:     'never'   ,// 'always'|'once'|'never'
showHints:          'once'    ,// 'always'|'once'|'never'
enableWrap:          true     ,// true|false
enableKeyboardNav:   true     ,// true|false
outsideClickCloses:  true     ,// true|false
imageClickCloses:    false    ,// true|false
numIndexLinks:       0        ,// number, -1 = no limit
showIndexThumbs:     true     ,// true|false
maxIndexThumbSize:   0        ,// pixels, 0 = native size
/*** </Navigation Options> ***/

/*** <Slideshow Options> ***/
doSlideshow:    false  ,// true|false
slideInterval:  4.5    ,// seconds
endTask:       'exit'  ,// 'stop'|'exit'|'loop'
showPlayPause:  true   ,// true|false
startPaused:    false  ,// true|false
pauseOnPrev:    true   ,// true|false
pauseOnNext:    false  ,// true|false
pauseOnResize:  true    // true|false
/*** </Slideshow Options> ***/
};

/*** <New Child Window Options> ***/
// Will inherit from the primary floatbox options unless overridden here.
// Add any you like.
this.childOptions = {
padding:             16,
overlayOpacity:      45,
resizeDuration:       3,
imageFadeDuration:    3,
overlayFadeDuration:  0
};
/*** </New Child Window Options> ***/

/*** <Custom Paths> ***/
// Normally leave these blank.
// Floatbox will auto-find folders based on the location of floatbox.js and background-images.
// If you have a custom odd-ball configuration, fill in the details here.
// (Trailing slashes please)
this.customPaths = {
	installBase: ''  ,// default: parsed from floatbox.js, framebox.js or floatbox.css include line
	jsModules: ''    ,// default: installBase/modules/
	cssModules: ''   ,// default: installBase/modules/
	languages: ''    ,// default: installBase/languages/
	graphics: ''      // default: from floatbox.css pathChecker background-image
};
/*** </Custom Paths> ***/

/***** END OPTIONS CONFIGURATION *****/
this.init();
}
Floatbox.prototype={version:"3.54.3",magicClass:"floatbox",cycleClass:"fbCycler",panelGap:20,infoLinkGap:16,draggerSize:12,controlOpacity:60,showHintsTime:1600,zoomPopBorder:1,controlSpacing:8,minCaptionWidth:50,ctrlJump:5,slowLoadDelay:750,autoFitSpace:5,maxInitialSize:120,minInitialSize:70,defaultWidth:"85%",defaultHeight:"82%",init:function(){var d=this;d.doc=document;d.docEl=d.doc.documentElement;d.head=d.doc.getElementsByTagName("head")[0];d.bod=d.doc.getElementsByTagName("body")[0];d.getGlobalOptions();d.currentSet=[];d.nodes=[];d.hiddenEls=[];d.timeouts={};d.pos={};var f=navigator.userAgent,a=navigator.appVersion;d.mac=a.indexOf("Macintosh")!==-1;d.speedBoost=1;if(window.opera){d.opera=true;d.operaOld=parseFloat(a)<9.5;if(d.operaOld){d.speedBoost=1.5}}else{if(document.all){d.ie=true;var g=d.doc.createElement("div");g.innerHTML='<!--[if gte IE 8]><div id="fb_ieNew"></div><![endif]--><!--[if lt IE 7]><div id="fb_ieOld"></div><![endif]-->';d.ieNew=!!g.firstChild&&g.firstChild.id==="fb_ieNew";d.ieOld=!!g.firstChild&&g.firstChild.id==="fb_ieOld";d.ieXP=parseInt(a.substring(a.indexOf("Windows NT")+11),10)<6;d.speedBoost=d.ieNew?1.9:1.2}else{if(f.indexOf("Firefox")!==-1){d.ff=true;d.ffOld=parseInt(f.substring(f.indexOf("Firefox")+8),10)<3;d.ffNew=!d.ffOld;d.ffMac=d.mac}else{if(a.indexOf("WebKit")!==-1){d.webkit=true;d.webkitMac=d.mac}else{if(f.indexOf("SeaMonkey")!==-1){d.seaMonkey=true}}}}}d.browserLanguage=(navigator.language||navigator.userLanguage||navigator.systemLanguage||navigator.browserLanguage||"en").substring(0,2);d.isChild=!!self.fb;if(!d.isChild){d.parent=d.lastChild=d;d.anchors=[];d.children=[];d.popups=[];d.cycleDivs=[];d.preloads={};d.base=(location.protocol+"//"+location.host).toLowerCase();var e=function(i){return i},c=function(i){return i&&d.doAnimations&&d.resizeDuration};d.modules={enableKeyboardNav:{files:["keydownHandler.js"],test:e},enableDragMove:{files:["mousedownHandler.js"],test:e},enableDragResize:{files:["mousedownHandler.js"],test:e},centerOnResize:{files:["resizeHandler.js"],test:e},showPrint:{files:["printContents.js"],test:e},zoomImageStart:{files:["zoomInOut.js"],test:c},loaded:{}};d.installFolder=d.customPaths.installBase||d.getPath("script","src",/(.*)f(?:loat|rame)box.js(?:\?|$)/i)||d.getPath("link","href",/(.*)floatbox.css(?:\?|$)/i)||"/floatbox/";d.jsModulesFolder=d.customPaths.jsModules||d.installFolder+"modules/";d.cssModulesFolder=d.customPaths.cssModules||d.installFolder+"modules/";d.languagesFolder=d.customPaths.languages||d.installFolder+"languages/";d.graphicsFolder=d.customPaths.graphics;if(!d.graphicsFolder){var b,g=d.doc.createElement("div");g.id="fbPathChecker";d.bod.appendChild(g);if((b=/(?:url\()?["']?(.*)blank.gif["']?\)?$/i.exec(d.getStyle(g,"background-image")))){d.graphicsFolder=b[1]}d.bod.removeChild(g);delete g;if(!d.graphicsFolder){d.graphicsFolder=(d.getPath("link","href",/(.*)floatbox.css(?:\?|$)/i)||"/floatbox/")+"graphics/"}}d.rtl=d.getStyle(d.bod,"direction")==="rtl"||d.getStyle(d.docEl,"direction")==="rtl"}else{d.parent=fb.lastChild;fb.lastChild=d;fb.children.push(d);d.anchors=fb.anchors;d.popups=fb.popups;d.cycleDivs=fb.cycleDivs;d.preloads=fb.preloads;d.modules=fb.modules;d.jsModulesFolder=fb.jsModulesFolder;d.cssModulesFolder=fb.cssModulesFolder;d.languagesFolder=fb.languagesFolder;d.graphicsFolder=fb.graphicsFolder;d.strings=fb.strings;d.rtl=fb.rtl;if(d.parent.isSlideshow){d.parent.pause(true)}}var h=d.graphicsFolder;d.resizeUpCursor=h+"magnify_plus.cur";d.resizeDownCursor=h+"magnify_minus.cur";d.notFoundImg=h+"404.jpg";d.blank=h+"blank.gif";d.zIndex={base:90000+(d.isChild?12*fb.children.length:0),fbOverlay:1,fbBox:2,fbCanvas:3,fbContent:4,fbMainLoader:5,fbLeftNav:6,fbRightNav:6,fbOverlayPrev:7,fbOverlayNext:7,fbResizer:8,fbtlPanel:9,fbtrPanel:9,fbblPanel:9,fbbrPanel:9,fbDragger:10,fbZoomDiv:11};var b=/\bautoStart=(.+?)(?:&|$)/i.exec(location.search);d.autoHref=b?b[1]:false},tagAnchors:function(c){var b=this;c=fb$(c)||document;function a(e){var g=c.getElementsByTagName(e);for(var f=0,d=g.length;f<d;f++){b.tagOneAnchor(g[f],false)}}a("a");a("area");if(!fb.licenseKey){b.getModule("licenseKey.js")}b.getModule("core.js");b.getModules(b.defaultOptions,true);b.getModules(b.pageOptions,false);if(b.popups.length){b.getModule("tagPopup.js");if(b.tagPopup){while(b.popups.length){b.tagPopup(b.popups.pop())}}}if(b.ieOld){b.getModule("ieOld.js")}},tagOneAnchor:function(h,l){var o=this,b=!!h.getAttribute,k;if(b){var m={href:h.getAttribute("href")||"",rev:h.getAttribute("data-fb-options")||h.getAttribute("rev")||"",rel:h.getAttribute("rel")||"",title:h.getAttribute("title")||"",className:h.className||"",ownerDoc:h.ownerDocument,anchor:h,thumb:(h.getElementsByTagName("img")||[])[0]}}else{var m=h;m.anchor=m.thumb=m.ownerDoc=false}if((k=new RegExp("(?:^|\\s)"+o.magicClass+"(\\S*)","i").exec(m.className))){m.tagged=true;if(k[1]){m.group=k[1]}}if(o.autoGallery&&!m.tagged&&m.rel!=="nofloatbox"&&(!m.className||m.className.indexOf("nofloatbox")===-1)&&o.fileType(m.href)==="img"){m.tagged=true;m.group=".autoGallery";if(o.autoTitle&&!m.title){m.title=o.autoTitle}}if(!m.tagged){if((k=/^(?:floatbox|gallery|iframe|slideshow|lytebox|lyteshow|lyteframe|lightbox)(.*)/i.exec(m.rel))){m.tagged=true;m.group=k[1];if(/^(slide|lyte)show/i.test(m.rel)){m.rev+=" doSlideshow:true"}else{if(/^(i|lyte)frame/i.test(m.rel)){m.rev+=" type:iframe"}}}}if(m.thumb&&((k=/(?:^|\s)fbPop(up|down|left|right)(?:\s|$)/i.exec(h.className)))){m.popup=true;m.popupType=k[1];o.popups.push(m)}if(l!==false){m.tagged=true}if(m.tagged){m.options={};if(window.fbClassOptions){var f=/(?:^|\s)(\S+)(?:\s|$)/g,k;f.lastIndex=0;while((k=f.exec(m.className))){if(fbClassOptions[k[1]]){o.parseOptionString(fbClassOptions[k[1]],m.options)}f.lastIndex--}}o.parseOptionString(m.rev,m.options);m.href=o.decodeHTML(m.options.href||m.href||"");m.group=m.options.group||m.group||"";if(!m.href&&m.options.showThis!==false){return}m.level=fb.children.length+(fb.lastChild.fbBox&&!m.options.sameBox?1:0);var g=o.anchors.length;while(g--){var j=o.anchors[g];if(j.href===m.href&&j.rev===m.rev&&j.rel===m.rel&&j.title===m.title&&j.html===m.html&&j.level===m.level&&(m.level||j.anchor===m.anchor||(m.ownerDoc&&m.ownerDoc!==o.doc))){j.anchor=m.anchor;j.thumb=m.thumb;m=j;break}}if(g===-1){if(m.options.type){m.options.type=m.options.type.replace(/^(flash|quicktime|wmp|silverlight)$/i,"media:$1");if(m.options.type==="image"){m.options.type="img"}}if(m.html){m.type="direct"}else{m.type=m.options.type||o.fileType(m.href)}if(m.type==="html"){m.type="iframe";var k=/#([A-Za-z]\S*)/.exec(m.href);if(k){var n=document;if(m.anchor){n=m.ownerDoc||n}if(n===document&&o.itemToShow&&o.itemToShow.anchor){n=o.itemToShow.ownerDoc||n}var d=n.getElementById(k[1]);if(d){m.type="inline";m.sourceEl=d}}}o.anchors.push(m);o.getModules(m.options,false);if(m.type.indexOf("media")===0){o.getModule("mediaHTML.js")}if(o.autoHref){if(m.options.showThis!==false&&o.autoHref===m.href.substring(m.href.length-o.autoHref.length)){o.autoStart=m}}else{if(m.options.autoStart===true){o.autoStart=m}else{if(m.options.autoStart==="once"){var k=/fbAutoShown=(.+?)(?:;|$)/.exec(document.cookie),e=k?k[1]:"",c=escape(m.href);if(e.indexOf(c)===-1){o.autoStart=m;document.cookie="fbAutoShown="+e+c+"; path=/"}}}}if(o.ieOld&&m.anchor){m.anchor.hideFocus="true"}}if(b){h.onclick=function(i){if(!i){var a=this.ownerDocument;i=a&&a.parentWindow&&a.parentWindow.event}if(!(i&&(i.ctrlKey||i.metaKey||i.shiftKey||i.altKey))||m.options.showThis===false||!/img|iframe/.test(m.type)){o.start(this);return o.stopEvent(i)}}}}if(l===true){return m}},tagDivs:function(b){var a=this;if(a.getElementsByClassName(a.cycleClass,b).length){a.getModule("cycler.js");a.cycleInit(b)}},fileType:function(b){if(!b){return"html"}var f=b,e=f.indexOf("?"),a="",d,g={youtube:/\.com\/(watch\?v=|watch\?(.+)&v=|v\/[\w\-]+)/,"video.yahoo":/\.com\/watch\/\w+\/\w+/,dailymotion:/\.com\/swf\/\w+/,vimeo:/\.com\/\w+/};
if(e!==-1){f=f.substring(0,e)}a=f.substring(f.lastIndexOf(".")+1).toLowerCase();if(/^(jpe?g|png|gif|bmp)$/.test(a)){return"img"}if(/^(html?|php[1-9]?|aspx?)$/.test(a)){return"html"}if(a==="swf"){return"media:flash"}if(a==="xap"){return"media:silverlight"}if(/^(mov|mpe?g|movie|3gp|3g2|m4v|mp4|qt)$/.test(a)){return"media:quicktime"}if(/^(wmv?|avi|asf)$/.test(a)){return"media:wmp"}if((d=/^(?:http:)?\/\/(?:www.)?([a-z\.]+)\.com\//i.exec(f))&&d[1]){var c=d[1].toLowerCase();if(g[c]&&g[c].test(b)){return"media:flash"}}return"html"},getGlobalOptions:function(){var c=this;if(!c.isChild){c.setOptions(c.defaultOptions);if(typeof setFloatboxOptions==="function"){setFloatboxOptions()}c.pageOptions=c.typeOf(self.fbPageOptions)==="object"?fbPageOptions:{}}else{for(var b in c.defaultOptions){if(c.defaultOptions.hasOwnProperty(b)){c[b]=c.parent[b]}}c.setOptions(c.childOptions);c.pageOptions={};for(var b in c.parent.pageOptions){if(c.parent.pageOptions.hasOwnProperty(b)){c.pageOptions[b]=c.parent.pageOptions[b]}}if(c.typeOf(self.fbChildOptions)==="object"){for(var b in fbChildOptions){if(fbChildOptions.hasOwnProperty(b)){c.pageOptions[b]=fbChildOptions[b]}}}}c.setOptions(c.pageOptions);if(c.pageOptions.enableCookies){var a=/fbOptions=(.+?)(;|$)/.exec(document.cookie);if(a){c.setOptions(c.parseOptionString(a[1]))}}if(c.pageOptions.enableQueryStringOptions||(location.search&&location.search.indexOf("enableQueryStringOptions=true")!==-1)){c.setOptions(c.parseOptionString(location.search.substring(1)))}},parseOptionString:function(h,b){var l=this;if(!h){return{}}var g=[],e,c=/`([^`]*?)`/g;c.lastIndex=0;while((e=c.exec(h))){g.push(e[1])}if(g.length){h=h.replace(c,"``")}h=h.replace(/\s*[:=]\s*/g,":");h=h.replace(/\s*[;&]\s*/g," ");h=h.replace(/^\s+|\s+$/g,"");h=h.replace(/(:\d+)px\b/gi,function(i,m){return m});b=b||{};var f=h.split(" "),d=f.length;while(d--){var k=f[d].split(":"),a=k[0],j=k[1];if(typeof j==="string"){if(!isNaN(j)){j=+j}else{if(j==="true"){j=true}else{if(j==="false"){j=false}}}}if(j==="``"){j=g.pop()||""}b[a]=j}return b},setOptions:function(d){var b=this;for(var a in d){if(b.defaultOptions.hasOwnProperty(a)){if(a==="licenseKey"){var c=window.fb||b;c.licenseKey=c.licenseKey||d[a]}else{b[a]=d[a]}}}},getModule:function(e){var d=this;if(d.modules.loaded[e]){return}if(e.slice(-3)===".js"){var b="script",a={type:"text/javascript",src:(e.indexOf("licenseKey")===-1?d.jsModulesFolder:d.installFolder)+e}}else{var b="link",a={rel:"stylesheet",type:"text/css",href:d.cssModulesFolder+e}}var f=d.doc.createElement(b);for(var c in a){if(a.hasOwnProperty(c)){f.setAttribute(c,a[c])}}d.head.appendChild(f);d.modules.loaded[e]=true},getModules:function(c,g){var f=this;for(var b in c){if(f.modules.hasOwnProperty(b)){var e=f.modules[b],h=g?f[b]:c[b],a=0,d=e.files.length;while(d--){if(e.test(h)){f.getModule(e.files[d]);a++}}if(a===e.files.length){delete f.modules[b]}}}},getStyle:function(a,f){if(!((a=fb$(a))&&f)){return}if(window.getComputedStyle){f=f.replace(/([A-Z])/g,"-$1").toLowerCase();var e=a.ownerDocument&&(a.ownerDocument.defaultView||a.ownerDocument.parentWindow);return(e&&e.getComputedStyle&&e.getComputedStyle(a,"").getPropertyValue(f))||""}f=f.replace(/-(\w)/g,function(g,h){return h.toUpperCase()});if(a.currentStyle){var d=a.currentStyle[f]||"";if(/^[\.\d]+[^\.\d]/.test(d)&&!/^\d+px/i.test(d)){var c=a.ownerDocument,b=c.createElement("div");c.body.appendChild(b);b.style.left=d;d=b.style.pixelLeft+"px";c.body.removeChild(b)}return d}return a.style&&a.style[f]},getPath:function(b,a,g){var c,e=document.getElementsByTagName(b),d=e.length;while(d--){if((c=g.exec(e[d][a]))){var f=c[1].replace("compressed/","");return f||"./"}}return""},addEvent:function(b,c,a){if(!(b=fb$(b))){return}if(b.addEventListener){b.addEventListener(c,a,false)}else{if(b.attachEvent){b.attachEvent("on"+c,a)}else{b["prior"+c]=b["on"+c];b["on"+c]=a}}},removeEvent:function(b,c,a){if(!(b=fb$(b))){return}if(b.removeEventListener){b.removeEventListener(c,a,false)}else{if(b.detachEvent){b.detachEvent("on"+c,a)}else{b["on"+c]=b["prior"+c];delete b["prior"+c]}}},stopEvent:function(b){b=b||window.event;if(b){if(b.stopPropagation){b.stopPropagation()}if(b.preventDefault){b.preventDefault()}try{b.cancelBubble=true}catch(a){}try{b.returnValue=false}catch(a){}}return false},getElementsByClassName:function(g,f){f=fb$(f)||document.getElementsByTagName("body")[0];var d=[];if(f.getElementsByClassName){var b=f.getElementsByClassName(g),c=b.length;while(c--){d[c]=b[c]}}else{var h=new RegExp("(^|\\s)"+g+"(\\s|$)"),e=f.getElementsByTagName("*");for(var c=0,a=e.length;c<a;c++){if(h.test(e[c].className)){d.push(e[c])}}}return d},typeOf:function(a){var b=typeof a;if(b==="object"){if(a===null){b="null"}else{if(typeof a.length==="number"&&typeof a.splice==="function"&&!a.propertyIsEnumerable("length")){b="array"}}}return b},encodeHTML:function(a){return a.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")},decodeHTML:function(b){var a=b.replace(/&lt;/g,"<").replace(/&gt;/g,">").replace(/&quot;/g,'"').replace(/&apos;/g,"'").replace(/&amp;/g,"&");return a.replace(/&#(\d+);/g,function(c,d){return String.fromCharCode(+d)})},setInnerHTML:function(a,d){if(!(a=fb$(a))){return false}try{a.innerHTML=d;return true}catch(h){}try{var j=a.ownerDocument,f=j.createRange();f.selectNodeContents(a);f.deleteContents();if(d){var b=new DOMParser().parseFromString('<div xmlns="http://www.w3.org/1999/xhtml">'+d+"</div>","application/xhtml+xml;charset=utf-8"),k=b.documentElement.childNodes;for(var c=0,g=k.length;c<g;c++){a.appendChild(j.importNode(k[c],true))}}return true}catch(h){}return false},getOuterHTML:function(a){if(!(a=fb$(a))){return""}if(a.outerHTML){return a.outerHTML}var b=(a.ownerDocument||a.document).createElement("div");b.appendChild(a.cloneNode(true));return b.innerHTML},start:function(a){var b=this;setTimeout(function(){b.start(a)},100)},preload:function(a,c){var b=this;setTimeout(function(){b.preload(a,c)},250)},cycleInit:function(a){var b=this;setTimeout(function(){b.cycleInit(a)},250)},mediaHTML:function(b,e,d,a,f){var c=this;setTimeout(function(){c.mediaHTML(b,e,d,a,f)},100)},ajax:function(b){var a=this;setTimeout(function(){a.ajax(b)},100)}};var fb$=function(a){return(typeof a==="string"?(document.getElementById(a)||null):a)};var fb;function initfb(){if(arguments.callee.done){return}var a="self";if(true){if(self!==parent){try{if(self.location.host===parent.location.host&&self.location.protocol===parent.location.protocol){a="parent"}}catch(c){}if(a==="parent"&&!parent.fb){return setTimeout(arguments.callee,50)}}}arguments.callee.done=true;if(document.compatMode==="BackCompat"){alert("Floatbox does not support quirks mode.\nPage needs to have a valid doctype declaration.");return}fb=(a==="self"?new Floatbox():parent.fb);var b=self.document.getElementsByTagName("body")[0];fb.anchorCount=b.getElementsByTagName("a").length;fb.tagAnchors(b);fb.tagDivs(b)}(function(){function b(){initfb();if(!(self.fb&&self.fb.strings)){return setTimeout(arguments.callee,100)}var d=self.document.getElementsByTagName("body")[0],c=d.getElementsByTagName("a").length;if(c>fb.anchorCount){fb.tagAnchors(d)}if(fb.autoStart){if(fb.autoStart.ownerDoc===self.document){fb.setTimeout("start",function(){fb.start(fb.autoStart)},100)}}else{setTimeout(function(){if(fb.preloads.count===fb.undefined){fb.preload("",true)}},200)}}if(window.addEventListener){window.addEventListener("load",b,false)}else{if(window.attachEvent){window.attachEvent("onload",b)}else{var a=window.onload;window.onload=function(){if(typeof a==="function"){a()}b()}}}})();if(document.addEventListener){document.addEventListener("DOMContentLoaded",initfb,false)};(function(){/*@cc_on try{document.body.doScroll('left');return initfb();}catch(e){}/*@if (false) @*/if(/loaded|complete/.test(document.readyState))return initfb();/*@end @*/if(!initfb.done)setTimeout(arguments.callee, 30);})();