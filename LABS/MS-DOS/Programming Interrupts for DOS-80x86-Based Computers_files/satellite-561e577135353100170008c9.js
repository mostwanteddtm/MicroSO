var preview = 0;
if (getURLQueryParameterByName("voc") == "nowyouseeme") preview = 1;
if (getURLQueryParameterByName("voc") == "nowyoudont") preview = 2;

if (preview > 0 || Math.floor((Math.random() * 100) + 1) <= 5){
  if (getCookie("mcxSurveyQuarantine") == ""){
		/* Set cookie - Start */
    
    setCookie("mcxSurveyQuarantine", "mcxSurveyQuarantine", "/");
    setCookie("mcxSurveyQuarantine", "mcxSurveyQuarantine", "/", ".ni.com");
    
    /* Set cookie - End */
    
    /* Inject CSS to site - Start */
        
    var linkElement = document.createElement("link");
		
		linkElement.rel = "stylesheet";
		linkElement.type = "text/css";
		linkElement.href = "/widgets/survey/1.0/css/vocsurvey.css";
    document.head.appendChild(linkElement);
    
    /* Inject CSS to site - End */
    
    /* Get language from metatag - Start */

    var language = "";
    var localeCookie = getCookie("locale");
		if (localeCookie.substring(0,2) != "zh"){
    	localeCookie = localeCookie.substring(0,2);
    }

    switch(localeCookie) {
        case "fr": language = "French"; break;
        case "de": language = "German"; break;
        case "ko": language = "Korean"; break;
        case "en": language = "English"; break;
        case "it": language = "Italian"; break;
        case "ja": language = "Japanese"; break;
        case "pt": language = "Portuguese"; break;
        case "es": language = "Spanish (Latin America)"; break;
        case "zh-CN": language = "Chinese (Simplified)"; break;
        case "zh-TW": language = "Chinese (Traditional)"; break;
        default: language = "English";
    }
    
    /* Get language from metatag - End */

    /* Generate AABeacon - Start */
    
    function getAABeacon() {
    	var whitelist = ['AQB', 'mid', 'aid', 'vid', 'fid', 'AQE'];
      var foundSrc = '';
      for (var p in window) {
      	if ((p.substring(0, 4) == 's_i_') && (window[p].src)) {
        	var src = window[p].src;
          if (src.indexOf('/b/ss/') >= 0) {
          	foundSrc = src;
            break;
          }
        }
      }

      if (!foundSrc && window.document.images) {
      	for (var image_num = 0; image_num < window.document.images.length; image_num++) {
        	var src = window.document.images[image_num].src;
          if (src.indexOf('/b/ss/') >= 0) {
          	foundSrc = src;
          	break;
      		}
      	}
    	}
              
    	if (!foundSrc){
    		return '';
    	}
             
    	var mainURL = foundSrc.substring(0, foundSrc.indexOf('?'));
    	var query = foundSrc.substring(foundSrc.indexOf('?') + 1);
    	var filteredQuery = '';
              
    	for (var i = 0; i < whitelist.length; i++) {
    		var v = getQueryValue(whitelist[i], query);
      	if (v) filteredQuery += (filteredQuery ? '&' : '') + whitelist[i] + '=' + v;
    	}
              
    	return mainURL + '?' + filteredQuery;
  	}
              
    function getQueryValue(variable, query) {
    	var vars = query.split('&');
      for (var i = 0; i < vars.length; i++) {
      	var pair = vars[i].split('=');
        if (decodeURIComponent(pair[0]) == variable) {
        	return decodeURIComponent(pair[1]);
        }
      }
    }
    
    /* Generate AABeacon - End */
    
    /* Generate CustomerID - Start */
    
    function readProfileID (){
    	var nameEQ = "profile_id=";
    	var ca = document.cookie.split(';');
    	for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    	}
    	return "Not logged in";
		}
    
    /* Generate CustomerID - End */
    
    /* Put URL together - Start */
    
    niVOCSurveyURL = "https://ni.allegiancetech.com/cgi-bin/qwebcorporate.dll?idx=PTW4N4";
    niVOCSurveyURL = niVOCSurveyURL + "&l=" + language;
    niVOCSurveyURL = niVOCSurveyURL + "&AABeacon=" + getAABeacon();
    niVOCSurveyURL = niVOCSurveyURL + "&CustomerID=" + readProfileID();
    niVOCSurveyURL = niVOCSurveyURL + "&URL=" + window.location.href;
    if (preview == 2){
    	niVOCSurveyURL = niVOCSurveyURL + "&preview=1";
    }
    /* Put URL together - End */
		
    /* Calling the modal - Start */
    
    window.setTimeout(prepareSurveyModal, 5000);
    
    /* Calling the modal - End */
  }
}

function setCookie(cname, cvalue, sPath, domain) {
    var d = new Date();
    d.setTime(d.getTime() + (365*24*60*60*1000));
    var expires = "expires="+d.toUTCString();     
    document.cookie = encodeURIComponent(cname) + "=" + encodeURIComponent(cvalue) + "; " + expires + (domain ? "; domain=" + domain : "") + (sPath ? "; path=" + sPath : "");
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
}

function getURLQueryParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(window.location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
