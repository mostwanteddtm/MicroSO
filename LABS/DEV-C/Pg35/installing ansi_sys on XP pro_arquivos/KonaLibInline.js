if(!window.KONA_VERSION){window.KONA_VERSION="2012_06_25"}if(window.parent!==window&&!window.dc_Frames){try{if(window.parent.location.href!==window.location.href){window.konaBeenHere=true}}catch(e){window.konaBeenHere=true}}if(window.konaBeenHere!==true){window.konaBeenHere=true;function konaGetTime(){return new Date().getTime()}var konaStartTime=konaGetTime();var KONTERA_INTERFACE={};(function(){var h=false;var b;var d=false;var g=[];function f(){if(!d){if(!document.body){return setTimeout(f,13)}d=true;for(var k=0;k<g.length;k+=1){g[k].call(document)}}}if(document.addEventListener){b=function(){document.removeEventListener("DOMContentLoaded",b,false);f()}}else{if(document.attachEvent){b=function(){if(document.readyState==="complete"){document.detachEvent("onreadystatechange",b);f()}}}}function a(){if(d){return}try{document.documentElement.doScroll("left")}catch(k){setTimeout(a,1);return}f()}function c(){if(h){return}h=true;if(document.readyState==="complete"){return f()}if(document.addEventListener){document.addEventListener("DOMContentLoaded",b,false);window.addEventListener("load",f,false)}else{if(document.attachEvent){document.attachEvent("onreadystatechange",b);window.attachEvent("onload",f);var k=false;try{k=(window.frameElement===null)}catch(l){}if(document.documentElement.doScroll&&k){a()}}}}KONTERA_INTERFACE.ready=function(k){c();if(d){k.call(document)}else{if(g){g.push(k)}}}}());function isWindows(){if(navigator.userAgent.indexOf("Windows")!==-1){return true}else{return false}}function isMac(){if(navigator.userAgent.indexOf("Mac")!==-1){return true}else{return false}}function getQueryVariable(b){var a="";var d=window.location.search.substring(1);var g=null;var f=d.split("&");for(var c=0;c<f.length;c+=1){g=f[c].split("=");if(g[0]===b){a=g[1]}}return a}function kona$(a){return document.getElementById(a)}function exploreDomainName(){var b=konaThisURL.toLowerCase();var f="";var d;var a;if(b.indexOf("http://www")===0||b.indexOf("https://www")===0){a=b.indexOf("http://www")+11;f=(b.substring(a,b.length));if(f.indexOf("/")>-1){f=f.substring(0,f.indexOf("/"))}d=0}else{if(b.indexOf("http://")===0||b.indexOf("https://")===0){a=b.indexOf("http://")+7;f=(b.substring(a,b.length));var g=0;for(var c=0;c<f.length;c+=1){if(f.charAt(c)==="."){g+=1}}if(g>1){f=(f.substring(f.indexOf(".")+1,f.length))}if(f.indexOf("/")>-1){f=f.substring(0,f.indexOf("/"))}d=1}else{if(b.indexOf("/")>-1){a=b.indexOf("/");f=(b.substring(0,a));d=2}}}if(f.length<=4){f=b}return f}function isInArray(c,b){for(var a=0;a<c.length;a+=1){if(c[a]===b){return true}}return false}function KonaHash(){this.length=0;this.items=[];for(var a=0;a<arguments.length;a+=2){if(typeof(arguments[a+1])!=="undefined"){this.items[arguments[a]]=arguments[a+1];this.length+=1}}this.removeItem=function(c){var b;if(typeof(this.items[c])!=="undefined"){this.length-=1;b=this.items[c];delete this.items[c]}return b};this.getItem=function(b){return this.items[b]};this.setItem=function(b,c){if(typeof(c)!=="undefined"){if(typeof(this.items[b])==="undefined"){this.length+=1}this.items[b]=c}return c};this.hasItem=function(b){return typeof(this.items[b])!=="undefined"}}function readCookie(d){var b=document.cookie.split("; ");for(var c=0;c<b.length;c+=1){var a=b[c].split("=");if(d===a[0]){return unescape(a[1])}}return null}function createKonaCookie(c,f,d){var a="";if(d){var b=new Date();b.setTime(b.getTime()+(d*24*60*60*1000));a="; expires="+b.toGMTString()}document.cookie=c+"="+f+a+"; path=/"}function eraseKonaCookie(a){createKonaCookie(a,"",-1)}function getFlashFullVersion(){var b="?";if(navigator.plugins&&navigator.mimeTypes.length){var a=navigator.plugins["Shockwave Flash"];if(a&&a.description){return a.description}}else{var c;try{c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7")}catch(g){try{c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");b=[6,0,21];c.AllowScriptAccess="always"}catch(f){if(b[0]===6){return b}}try{c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash")}catch(d){}}if(c&&c.GetVariable("$version")){return c.GetVariable("$version")}}return b}function getFlashVersion(){var b=[0,0,0];if(navigator.plugins&&navigator.mimeTypes.length){var a=navigator.plugins["Shockwave Flash"];if(a&&a.description){b=a.description.replace(/([a-zA-Z]|\s)+/,"").replace(/(\s+r|\s+b[0-9]+)/,".").split(".")}}else{var c;try{c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7")}catch(g){try{c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");b=[6,0,21];c.AllowScriptAccess="always"}catch(f){if(b[0]===6){return b}}try{c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash")}catch(d){}}if(c){b=c.GetVariable("$version").split(" ")[1].split(",")}}return b}function checkFlashSupport(){var a=getFlashVersion();if(a[0]>=8&&!KONTERA_INTERFACE.isMobile){window.hasRMFlashSupport=true}}function checkFlashSupportForHybrid(){var a=getFlashVersion();if(a[0]>=9){return true}return false}var konaStartTime=new Date().getTime();var konaPageLoadMeasureReport={};KONTERA_INTERFACE.ready(function(){konaPageLoadMeasureReport.pr=new Date().getTime()-konaStartTime});var TWEAK_MODE_DEFAULT=0;var konaTweakMode=TWEAK_MODE_DEFAULT;KONTERA_INTERFACE.trace=function(){if(typeof(window.console)!=="undefined"){if(typeof(window.console.log)==="function"){window.console.log.apply(window.console,arguments)}}};var konalogMode=false;var isKonaFirst=false;if(typeof(window.konaSuffix)==="undefined"){window.konaSuffix="?00000000482";isKonaFirst=true}KONTERA_INTERFACE.isMobile=navigator.userAgent.match(/Windows Phone|Android|iPhone|iPad|J2ME|Symbian|BlackBerry|sonyericsson|nokia|Windows CE|Opera Mini/i)||document.location.search.match(/(kona_iphone|kona_android)=1/);KONTERA_INTERFACE.isTapestrySession=function(){return !!getQueryVariable("kona_tapestry")};(function(){if(window.KONA_PREV_VERSION){var c=90;var d=50;var a=(KONTERA_INTERFACE.isMobile?d:c);window.konaAB_JSVersion=window.konaAB_JSVersion||a;var b=Math.random()*100;if(b<window.konaAB_JSVersion){KONA_VERSION=KONA_PREV_VERSION}else{konaTweakMode|=(1<<2)}}if(getQueryVariable("konadir")){KONA_VERSION=getQueryVariable("konadir")}}());var konaDate="24_03_2010";var bOpera=(navigator.userAgent.toLowerCase().indexOf("opera")!==-1);var bAvant=(navigator.userAgent.toLowerCase().indexOf("avant")!==-1);var bIE=(!bOpera&&navigator.appName.indexOf("Microsoft")!==-1);var bIE6=(bIE&&navigator.userAgent.charAt(30)===6);var bIE8=(bIE&&navigator.userAgent.indexOf("MSIE 8")!==-1);var bChrome=(navigator.userAgent.toLowerCase().indexOf("chrome")!==-1);var bFlock=(navigator.userAgent.toLowerCase().indexOf("flock")!==-1);var bSafari=(navigator.userAgent.toLowerCase().indexOf("safari")!==-1);var bMozilla=(!bOpera&&!bIE&&!bSafari&&!bFlock);var bFireFox2=(bMozilla&&(navigator.userAgent.indexOf("Firefox/2")!==-1));var bFireFox3=(bMozilla&&(navigator.userAgent.indexOf("Firefox/3")!==-1));var bUnknown=(!bMozilla&&!bFireFox2&&!bFireFox3);if(typeof(window.HTTP_KONA)==="undefined"){window.HTTP_KONA="http://kona.kontera.com"}if(typeof(window.HTTP_KONAC)==="undefined"){window.HTTP_KONAC="http://konac.kontera.com"}var HTTP_KONAX="http://konax.kontera.com";var HTTP_IMAGES="http://images.kontera.com";if(window.location.protocol==="https:"){HTTP_KONA="https://secure-js.kontera.com";HTTP_KONAC="https://secure-js.kontera.com";HTTP_IMAGES="https://secure-js.kontera.com"}if(getQueryVariable("konaip")){HTTP_KONA="http://"+getQueryVariable("konaip");HTTP_KONAC="http://"+getQueryVariable("konaip")}var HTTP_KONTERA_BASE=HTTP_KONA;var konaUserID="";var konaSessionID="";var konaBaseHere=false;var konaRetry=300;var delayJSFlowBY=-1;var isNewLayer=false;var isBritannicaFF3=bFireFox3;var problematicAdverisers=[];if(!KONTERA_INTERFACE.write){KONTERA_INTERFACE.write=function(a){document.write(a)}}if(typeof(window.dc_flowMode)==="undefined"){window.dc_flowMode=0}if(window.location.search.match("konaflow")){window.dc_flowMode=parseInt(getQueryVariable("konaflow"),10)}if(typeof(window.dc_flowByCommand)==="undefined"){dc_flowByCommand=false}if(window.dc_flowMode===1||window.dc_flowMode===3){if(typeof(window.dc_startInterval)==="undefined"){window.dc_startInterval=0}else{window.delayJSFlowBY=window.dc_startInterval}}var isDynamicContent;if(window.dc_flowMode===2||window.dc_flowMode===4){isDynamicContent=true}if(window.dc_flowMode===3){dc_flowByCommand=true}if(dc_PublisherID===31107){dc_PublisherID=87143}var konaHCdemo=-1;var konaThisURL=window.location.toString();var isRestrictedUrl=false;var konaHCdemoUrls=new KonaHash("http://www.mensfitness.com/nutrition/vitamins/194",0,"http://www.mensfitness.com/sports_and_recreation/outdoor_recreation/55",1,"http://www.mensfitness.com/Tshirt_Workout/fitness/ab_exercises/136?cid=RSS",2,"http://www.shape.com/workouts/articles/workout_schedule.html",3,"http://www.shape.com/workouts/articles/blood_sugar.html",4,"http://www.huffingtonpost.com/2008/11/16/paul-mccartney-hopes-to-r_n_144138.html",5);if(konaHCdemoUrls.hasItem(konaThisURL)){konaHCdemo=konaHCdemoUrls.getItem(konaThisURL)}konaHCdemoUrls=null;var hybridGroup=new KonaHash(7792,1,10747,1,47839,1,52730,1,32100,1,38144,1,64727,1,70447,1,70448,1,73310,1);if(hybridGroup.hasItem(dc_PublisherID)){if((dc_PublisherID!==32100)&&(dc_PublisherID!==7792)&&(dc_PublisherID!==10747)){konaTweakMode|=32768}}var dynamicContentPubs=[50635,50201,50629,50630];isDynamicContent|=isInArray(dynamicContentPubs,dc_PublisherID);var isForcedDynamicContent=false;var forcedDynamicContentPubs=new KonaHash(104880,bIE);if(forcedDynamicContentPubs.hasItem(dc_PublisherID)){isForcedDynamicContent=forcedDynamicContentPubs.getItem(dc_PublisherID)}if(dc_PublisherID===48817){var restrictedUrlGroup=["http://it.toolbox.com/blogs/ppmtoday","http://it.toolbox.com/blogs/db2luw","http://it.toolbox.com/blogs/db2zos","http://it.toolbox.com/blogs/elsua","http://it.toolbox.com/blogs/database-talk","http://it.toolbox.com/blogs/penguinista-databasiensis","http://it.toolbox.com/blogs/juice-analytics","http://it.toolbox.com/blogs/minimalit","http://it.toolbox.com/blogs/database-soup","http://blogs.ittoolbox.com/pm/ppm"];for(var j=0;j<restrictedUrlGroup.length;j+=1){if(konaThisURL.toLowerCase().indexOf(restrictedUrlGroup[j].toLowerCase())!==-1){isRestrictedUrl=true;break}}}var konaHCdelayPagesUrls=["http://autospies.com/","http://autospies.com/news/recent.aspx"];var adPreviewMode=false;if(typeof(window.dc_adPreview)!=="undefined"||typeof(window.dc_standAloneMode)!=="undefined"){adPreviewMode=true}var nladPreviewMode=false;if(typeof(window.dc_nladPreview)!=="undefined"){nladPreviewMode=true}var delayPageKeyPubs=[50517,73384,58050,85192,14429,23724,4130,14541,32528,7611,6682,8192,35725,8079,5278,4566,52987,12854,4213,40109,61456,76947,38115,52417,21401,48820,35061,7834,52993,50537,7795,73386,64532,29104,35267,50538,47547,36981,7283,15304,7121,72598,50375,6912,73395,32101,58816,64381,92562,144527,141351,141350,155821,58109,161007,161008,161009,161010,161011,161012,161013,161014,161015,161016,159088,167686,186783,187350,192506,195798,196319,191434,191137,187350,188147,188075];function handlePageKey(){if(isInArray(delayPageKeyPubs,dc_PublisherID)||isInArray(konaHCdelayPagesUrls,konaThisURL)||window.dc_flowMode===3){return true}else{return false}}var isDelayPageKey=handlePageKey();var sName="KonaBase.js";var userInteractionBaseJs;if(KONTERA_INTERFACE.isMobile){userInteractionBaseJs="KonaMobile.js"}else{userInteractionBaseJs="KonaFlashBase.js"}var newLayerGroupTailoring=false;var newLayerPublishersArray=[50198,70028,71869,71881,96216,74998,48414,100478,100480];var konaNonSupportedPlatform=false;if(dc_PublisherID===140070||dc_PublisherID===140073){konaNonSupportedPlatform=true}if(!KONTERA_INTERFACE.isMobile&&window.dc_MobileOnly===true){konaNonSupportedPlatform=true}KONTERA_INTERFACE.isRelatedDemo=(getQueryVariable("kona_related")==="1");if(isInArray(newLayerPublishersArray,dc_PublisherID)){var basePublisherPath=HTTP_KONA+"/javascript/lib/"+KONA_VERSION+"/flash/publishers_design/"+dc_PublisherID+"/";newLayerGroupTailoring=true;isNewLayer=true;sName="KonaInfra.js"}else{var isUserInteractionLayer;if(window.konaForceNewLayer){isUserInteractionLayer=true}else{if(getQueryVariable("konanl")){isUserInteractionLayer=(getQueryVariable("konanl")==="1")}else{if((!checkFlashSupportForHybrid()&&!KONTERA_INTERFACE.isMobile)){isUserInteractionLayer=false;window.hasRMFlashSupport=false}else{isUserInteractionLayer=true}}}}if(isUserInteractionLayer){isNewLayer=false;newLayerGroupTailoring=false;sName=userInteractionBaseJs;konaTweakMode|=Math.pow(2,16)}var isHybridForLinuxFlag=false;if(hybridGroup.hasItem(dc_PublisherID)&&((konaTweakMode&18432)>0||(konaTweakMode&32768)>0)){if(checkFlashSupportForHybrid()){isHybridForLinuxFlag=true;sName="FlashKonaLibBaseRM.js"}}if(!isNewLayer){var randCDN=Math.random()*100;if(randCDN<=80){konaTweakMode|=33554432;HTTP_KONTERA_BASE=HTTP_KONAC}else{HTTP_KONTERA_BASE=HTTP_KONA}}if(adPreviewMode){var sName="KonaBase.js"}var isCalledKonaBase=false;String.format=function(){if(arguments.length===0){return null}var c=arguments[0];for(var a=1;a<arguments.length;a+=1){var b=new RegExp("\\{"+(a-1)+"\\}","gm");c=c.replace(b,arguments[a])}return c};var tryToTraceRounds=5;function trace(a){if(typeof(jsTrace)!=="undefined"){jsTrace.send(a)}else{tryToTraceRounds-=1;if(tryToTraceRounds>0){setTimeout("trace('"+a+"')",500)}else{tryToTraceRounds=null}}}function logit(a){trace(a)}var KonaJSfiles=[];function scriptTagId(){var a="";if(dc_PublisherID===503){if(bIE6){a="ID='catfish-wrap'"}}return a}function startDynamicContentFlow(){if(window.dc_flowMode===0||window.dc_flowMode===1){return}if(window.dc_flowMode!==3){delayJSFlowBY=3000;isDynamicContent=true;if(!isCalledKonaBase){isCalledKonaBase=true;var b;for(var a=0;a<KonaJSfiles.length;a+=1){b=document.createElement("script");b.type="text/javascript";b.src=KonaJSfiles[a];document.getElementsByTagName("head")[0].appendChild(b)}}}if(typeof(konaBaseHere)!=="undefined"){if(konaBaseHere){checkDoRunOnPage();if(window.dc_flowMode===2){$JK.isReady=true;$JK(function(){})}dcInit()}else{konaRetry-=1;if(konaRetry>0){setTimeout(function(){startDynamicContentFlow()},75);return}}}}KONTERA_INTERFACE.loadTapestry=function(){var c="http://tapestry.kontera.com/lib/tapestry-loader.js";var a=scriptTagId();var b="<SCRIPT LANGUAGE='JavaScript' "+a+" SRC='"+c+"'></SCRIPT>";KONTERA_INTERFACE.write(b)};if(!konaNonSupportedPlatform){if(KONTERA_INTERFACE.isTapestrySession()){KONTERA_INTERFACE.loadTapestry()}else{if(isNewLayer){KonaJSfiles[KonaJSfiles.length]=basePublisherPath+"designParams.js"+konaSuffix}else{if(!isUserInteractionLayer){if(window.location.protocol==="http:"){var tagID=scriptTagId();var url=HTTP_KONAX+"/publisher_tail/generatedPublisherConfig.js?publisher_id="+dc_PublisherID;var scriptTags="<SCRIPT LANGUAGE='JavaScript' "+tagID+" SRC='"+url+"'></SCRIPT>";KONTERA_INTERFACE.write(scriptTags)}}}KonaJSfiles[KonaJSfiles.length]=HTTP_KONTERA_BASE+"/javascript/lib/"+KONA_VERSION+"/"+sName;if(typeof(dc_PublisherID)!=="undefined"){var scriptTags="";var disableKontera=readCookie("KonteraContentLink");var disableInfra=readCookie("disable_kontera");var tagID=scriptTagId();if(isRestrictedUrl||(isHybridForLinuxFlag&&(!isWindows()&&!isMac()))||(!checkFlashSupportForHybrid()&&(hybridGroup.hasItem(dc_PublisherID)))||disableKontera||disableInfra||dc_PublisherID===73310||isDynamicContent||!isKonaFirst){}else{if(!window.document||!window.document.body){var random=Math.floor(Math.random()*1001);KonaJSfiles=['http://kona32.kontera.com/KonaGet.js?MQKey=Errors&rId=dummy&ReportData={"JSVersion":"'+KONA_VERSION+'","url":"'+escape(window.location)+'","errorType":"badtag"}&r='+random]}for(var i=0;i<KonaJSfiles.length;i+=1){scriptTags="<SCRIPT LANGUAGE='JavaScript' "+tagID+" SRC='"+KonaJSfiles[i]+"'></SCRIPT>";KONTERA_INTERFACE.write(scriptTags)}}}hybridGroup=null;if(window.dc_flowMode===4){KONTERA_INTERFACE.ready(startDynamicContentFlow)}}}};