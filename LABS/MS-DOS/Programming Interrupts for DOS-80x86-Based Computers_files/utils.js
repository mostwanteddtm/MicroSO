/*
 * PNX Utils
 * @author Keegan Watkins 
 * 
 * Provides a toolbox for common tasks, i.e. cookies and popups
 */

// Namespace
var PNX = PNX || {};
PNX.utils = {};

(function(utils) {
	// Shortcuts
	var _encode = encodeURIComponent, 
		_decode = decodeURIComponent,
		_trim = $.trim,
		_merge = $.extend;

	// Returns the value of a given cookie, or null
	var _get = function(name) {
		var cookies = document.cookie.split( ";" ),
			cookie,
			cookieName,
			cookieValue;

		for (var i = 0, len = cookies.length; i < len; i++) {
			cookie = cookies[ i ].split( "=" );
			cookieName = _trim( cookie[0] );
			cookieValue = _decode( cookie[1] );
			if (cookieName === name) {
				return cookieValue;
			}
		}

		return null;
	};

	// Sets the complete, formatted cookie string 
	var _set = function(name, value, options) {
		var settings = [name + "=" + _encode( value ) ];
		
		options.path && settings.push( "path=" + options.path );
		options.domain && settings.push( "domain=" + options.domain );
		options.expires && settings.push( "expires=" + options.expires )
		options.secure === true && settings.push( "secure" );
		
		document.cookie = settings.join("; ");
	};

	// Public API
	var Cookie = utils.Cookie = {

		// The default settings to use for cookies, can be globally overwritten
		// by accessing NICore.cookie.defaults
		defaults: {
			path: "",
			domain: "",
			expires: "",
			secure: false
		},

		// Returns the cookie value for the given name, or null
		get: function(name) {
			return _get( name );
		},

		// Sets the cookie value for the given name
		set: function(name, value, options) {
			_set(name, value, _merge( {}, Cookie.defaults, options ));
			// Allow chaining
			return this;
		},

		// Removes the cookie value with the given name.
		remove: function(name, options) {
			// Merge the options with a date in the past, then merge with the
			// defaults (to allow path/domain/secure settings, which may be
			// needed to remove a cookie).
			var settings = _merge( {}, Cookie.defaults, 
				_merge( {}, options, {
					expires: (new Date(0)).toGMTString()
				})
			);
			// Allow chaining
			return Cookie.set( name, "", settings );
		}
	};
})( PNX.utils );

(function(utils) {
	
	// Creates and returns a popup window
	utils.Popup = function(url, title, options) {
		var arr = [];
		for (var prop in options) {
			options.hasOwnProperty(prop) && options[prop] && arr.push(prop + "=" + options[prop])
		}
		
		return window.open(url, title, arr.length ? arr.join(", ") : "");
	};
	
})( PNX.utils );


//VOC Surveys
var surveyPopup;
function prepareSurveyModal()
{
	getExtraKeysAndLaunch();
}	

function launchSurveyModal(extraKeys)
{
	var newHTMLContainer = '<div class="survey-launch-modal"><div class="modal-content">';
			newHTMLContainer += '<h3>'+ extraKeys['MODAL_TITLE'] +'</h4>';
			newHTMLContainer += '<div class="pnx-block-1x">'+ extraKeys['MODAL_GREETING'] +'</div>';
			newHTMLContainer += '<div class="pnx-block-1x"><strong>'+ extraKeys['MODAL_EXPERIENCE'] +'</strong></div>';
			newHTMLContainer += '<div class="pnx-block-2x font-size-s">'+ extraKeys['MODAL_POPUP_INFO'] +'</div>';
			newHTMLContainer += '<div class="clearfix center">';
			newHTMLContainer += '<span class="pnx-btn survey-no gutter-outer-r"><span class="pnx-btn-text">'+ extraKeys['MODAL_LEFT_BUTTON'] +'</span></span>';
			newHTMLContainer += '<span class="pnx-btn survey-yes"><span class="pnx-btn-text">'+ extraKeys['MODAL_RIGHT_BUTTON'] +'</span></span>';
			newHTMLContainer += '</div>';
			newHTMLContainer += '</div></div>';
	$('body').append(newHTMLContainer);
	
	$(".survey-launch-modal").dialog({
			autoOpen : false,
			modal : true,
			resizable : 'no',
			minWidth: 360,
			//title : 'modal window title 1',

			open : function(event, ui) {
					$('.ui-widget-overlay').click(function() {
							$('.modal-example').dialog('close');

					});
					$('.survey-yes').click(function(){sayYesToSurvey();});
					$('.survey-no').click(function(){sayNoToSurvey('.survey-launch-modal');});
			},
			close : function(event, ui) {
				 
					return false;
			}
	});

	$('.survey-launch-modal').dialog('open');
}

function sayNoToSurvey(modalClass)
{
	//close modal
	$(modalClass).dialog("close");
}

function sayYesToSurvey()
{
	//launch popup
	//niVOCSurveyURL
	surveyPopup = window.open('/apps/surveys/vocsurvey2015.html','SurveyModal','width=800,height=450,location=no,resizable=no,titlebar=no,menubar=no');
  sayNoToSurvey('.survey-launch-modal');
};

function getSurveyLanguage()
{
	var language = (($.cookie("locale")!== null) && (typeof($.cookie("locale"))!== 'undefined'))?$.cookie("locale"):'en';
	if (language.substring(0,2)=="zh")
	{
	 if (language == "zh-CN") language = "zhs";
	 if (language == "zh-TW" || language == "zh-HK") language = "zht";
	}
	language = language.replace(/\-.*/, "");
 
	return language;
}

function getExtraKeysAndLaunch()
{
	var lang = getSurveyLanguage() + '/';
	
	var hardEngData = {
		"MODAL_EXPERIENCE": "This survey is designed to measure your entire ni.com experience and so will appear at the end of your visit.",
		"MODAL_GREETING": "Thank you for visiting ni.com today.  In order to ensure we provide you with the best experience, we would like your feedback regarding this visit, so we can continuously improve.",
		"POPUP_DIRECTIONS": "When you have finished using ni.com, please switch back to this window to complete the survey.  For now, please click in the ni.com window to continue your session.",
		"MODAL_POPUP_INFO": "This survey  is conducted by an independent company, on behalf of National Instruments.",
		"MODAL_RIGHT_BUTTON": "Yes, I'll help",
		"POPUP_THANK_YOU": "Thank you for sharing your feedback.",
		"POPUP_LEAVE_OPEN": "Please leave this window open.",
		"MODAL_LEFT_BUTTON": "No, thanks",
		"MODAL_TITLE": "We welcome your feedback!"
	};
	
	$.ajax({
		url: "/extra-delivery-proxy/translation/Set/1.0/"+lang+"VOC-SURVEYS.json",
		context: document.body,
		timeout: 10000,
		success: function(data) {
			if ((typeof(data['MODAL_EXPERIENCE']) == 'undefined') || (data['MODAL_EXPERIENCE'] == 'undefined'))
			{
				launchSurveyModal(hardEngData);
			}
			else
			{
				launchSurveyModal(data);
			}
		},
		error: function() {
			launchSurveyModal(hardEngData);
		}
	});
}

/* For hand-testing the survey modal */
//$(document).ready(function(){
//	prepareSurveyModal();
//});
