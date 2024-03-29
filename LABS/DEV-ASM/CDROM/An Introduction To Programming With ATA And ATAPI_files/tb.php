/*! Required | Ezoic */
function ezdebug(msg) {
    if (did == 5322 || did == 416 || did == 4) {
        console.debug(msg);
    }
}
function ez_attachEvent(element, evt, func) {
    if (element.addEventListener) {
        element.addEventListener(evt, func, false);
    } else {
        element.attachEvent("on" + evt, func);
    }
}
function ez_attachEventWithCapture(element, evt, func, useCapture) {
    if (element.addEventListener) {
        element.addEventListener(evt, func, useCapture);
    } else {
        element.attachEvent("on" + evt, func);
    }
}
function ez_detachEvent(element, evt, func) {
    if(element.removeEventListener) {
        element.removeEventListener(evt, func);
    } else {
        element.detachEvent("on"+evt, func);
    }
}
function ez_getQueryString(field, url) {
    var href = url ? url : window.location.href;
    var reg = new RegExp('[?&]' + field + '=([^&#]*)', 'i');
    var string = reg.exec(href);
    return string ? string[1] : null;
};
/*! Required | Ezoic */if(typeof ct !== "undefined" && ct !== null) {
    ct.destroy();
}
var ct = {
    DEBUG : false,

    frameTimeoutId : -1,
    frameLoadCount : 0,
    frameElements : [],
    frameData : [],
    currentFrame : null,
    currentFrameIndex : -1,
    stopLoadFrames : false,
    loadFramesTimeoutMs : 800,

    ilLoadIntervalId : -1,
    ilLoadCount : 0,
    stopIlLoad : false,

    oldBrowser : false,

    eventLoopTimeoutId : -1,
    eventLoopRateMs : 100,

    lastActiveElement : null,
    windowHasFocus : false,
    documentHasFocus : false,

    activeFrameIndex : false,
    activeFrame : null,

    twoClickEventTimeoutId : null,

    clickTimeoutMs : 800,

    windowBlurFunc : null,
    windowFocusFunc : null,
    windowBeforeUnloadFunc : null,

    isInitialized : false,

    selectors : [
        [".ezoic_ad > .ezoic_ad", 2],
        [".ez_sa_ad", 2],
        [".ezo_ad > center > .ezoic-ad", 2],
        [".ezoic-ad > .ezoic-ad", 2],
        [".ezo_link_unit_a", 5],
        [".ezo_link_unit_m", 38],
        [".ezo_link_unit_unknown", 0],
        [".ezoic-ad > .OUTBRAIN > .ob-widget", 41],
        [".ezoic-ad > div[id *= 'taboola-'] > .trc_rbox_container", 37],
        [".ezflad", 46],
        [".ezflad-47", 47]
    ],
    init : function() {
        this.log("Init Func called");
        if(this.isInitialized === true) {
            this.log("Initialized already called before.  Not running again.");
            return;
        }
        this.initVars();
        this.loadFrames();

        var self = this;

        this.ilLoadIntervalId = setInterval(function(){self.loadILTrack()}, 500);

        this.startEventLoop();

        this.attachWindowEvents();

        this.isInitialized = true;
    },
    destroy : function() {
        this.log("Destroy Func called");
        this.unloadFrames();
        this.unloadIlTrack();

        this.unsetClickEvents();

        this.stopEventLoop();
        this.detachWindowEvents();
        this.isInitialized = false;
    },
    initVars : function() {
        this.log("Initialize Vars");
        this.frameTimeoutId = -1;
        this.frameLoadCount = 0;
        this.frameElements = [];
        this.frameData = [];
        this.currentFrame = null;
        this.currentFrameIndex = -1;
        this.stopLoadFrames = false;

        this.ilLoadIntervalId = -1;
        this.ilLoadCount = 0;
        this.stopIlLoad = false;

        this.oldBrowser = this.isUndefined(document.hasFocus);

        this.eventLoopTimeoutId = -1;
        this.eventLoopRateMs = 100;

        this.lastActiveElement = null;
        this.windowHasFocus = false;
        this.documentHasFocus = false;

        this.activeFrameIndex = false;
        this.activeFrame = null;

        this.twoClickEventTimeoutId = null;

        this.clickTimeoutMs = 800;

        this.windowBlurFunc = null;
        this.windowFocusFunc = null;
        this.windowBeforeUnloadFunc = null;

        this.isInitialized = false;
    },
    loadFrames : function() {
        this.log("Loading Frames");
        this.frameLoadCount++;
        for(var i = 0; i < this.selectors.length; i++) {
            var elems = document.querySelectorAll(this.selectors[i][0]);
            var statSourceId = this.selectors[i][1];
            for(var j = 0; j < elems.length; j++) {
                this.setClickEvents(elems[j], statSourceId);
            }
        }
        if(this.frameLoadCount > 40) {
            this.stopLoadFrames = true;
        }
        var self = this;
        if (this.stopLoadFrames == false) {
            this.frameTimeoutId = setTimeout(function(){self.loadFrames();}, this.loadFramesTimeoutMs);
        }
    },
    unloadFrames : function() {
        this.log("Unloading frames");
        this.stopLoadFrames = true;

        clearTimeout(this.frameTimeoutId);
    },
    setClickEvents : function(elem, statSourceId) {
        // Return if already set
        if(this.isUndefined(elem.ezo_flag) === false) {
            return;
        }

        this.log("Set Click Events for elem : " + elem.id);

        this.frameElements.push(elem);

        this.frameData.push({
            statSourceId: statSourceId,
            twoClickRecorded: false,
            navigationsRecorded: 0
        });

        var self = this;
        var index = this.frameElements.length - 1;
        elem.ezo_flag = true;
        elem.mouseOverFunc = function() {
            self.log("Mouse Over Func");
            self.currentFrame = this;
            self.currentFrameIndex = index;
        };
        elem.mouseOutFunc = function() {
            self.log("Mouse Out Func");
            self.currentFrame = null;
            self.currentFrameIndex = -1;
        };

        elem.clickFunc = function() {
            self.log("Click Func");
            self.currentFrame = this;
            self.currentFrameIndex = index;
            self.ezAwesomeClick(false, index);
        };

        ez_attachEvent(elem, "mouseover", elem.mouseOverFunc);
        ez_attachEvent(elem, "mouseout", elem.mouseOutFunc);

        if(statSourceId == 46) {
            ez_attachEventWithCapture(elem, "click", elem.clickFunc, true);
        }

        if(statSourceId === 4) {
            elem.mouseOverFuncIl = function() {
                self.log("Mouse Over Il Func");
                if(self.ilLoadCount > 30) {
                    self.ilLoadCount -= 30;
                }
                clearInterval(self.ilLoadIntervalId);

                self.ilLoadIntervalId = setInterval(function(){self.loadILTrack()}, 500);
            };
            ez_attachEvent(elem, "mouseover", elem.mouseOverFuncIl);
        }
        this.log("Finished Set Click Events");
    },
    unsetClickEvents : function() {
        this.log("Unset Click Events");
        while(this.frameElements.length) {
            var elem = this.frameElements.pop();

            if(this.isUndefined(elem) === false) {
                delete elem.ezo_flag;

                ez_detachEvent(elem, "mouseover", elem.mouseOverFunc);
                delete elem.mouseOverFunc;

                ez_detachEvent(elem, "mouseout", elem.mouseOutFunc);
                delete elem.mouseOutFunc;

                if(this.isUndefined(elem.mouseOverFuncIl) === false) {
                    ez_detachEvent(elem, "mouseover", elem.mouseOverFuncIl);
                    delete elem.mouseOverFuncIl;
                }
            }

            this.frameData.pop();
        }
        this.log("Finished unset Click Events");
    },
    loadILTrack : function() {
        this.ilLoadCount++;

        var elems = document.querySelectorAll("span.IL_AD, .IL_BASE");

        for(var i = 0; i < elems.length; i++) {
            var elem = elems[i];
            if(this.isUndefined(elem.ezo_flag) == false) {
                continue;
            }

            if(this.findParentsWithClass(elem, ["IL_AD", "IL_BASE"]) !== false) {
                this.setClickEvents(elem, 4);
            }
        }
        if(this.ilLoadCount > 55) {
            this.log("Il Load Count is over 55.  Stopping.");
            this.stopIlLoad = true;
        }
        if(this.stopIlLoad === true) {
            this.log("Clearing ilLoadInterval");
            clearInterval(this.ilLoadIntervalId);
        }
    },
    unloadIlTrack : function() {
        this.log("Unloading Il Track");
        this.stopIlLoad = true;

        clearInterval(this.ilLoadIntervalId);
    },
    startEventLoop : function() {
        this.log("Starting Event Loop");
        if(this.oldBrowser === true) {
            return;
        }

        var self = this;

        this.eventLoopTimeoutId = setTimeout(function() {self.doEventLoop()}, this.eventLoopRateMs);
    },
    doEventLoop : function() {
        if(this.oldBrowser === true) {
            return;
        }
        var docNowHasFocus = document.hasFocus() && !document.hidden;

        if (this.lastActiveElement !== document.activeElement) {
            if(this.windowHasFocus === false) {
                this.fixedWindowBlur();
            }
            this.lastActiveElement = document.activeElement;
            // If the active element switched, we know the document was momentarily focused on
            this.documentHasFocus = true;
        }

        if(this.documentHasFocus === true && docNowHasFocus === false) {
            this.documentBlur();
        }

        this.documentHasFocus = docNowHasFocus;
        var self = this;

        this.eventLoopTimeoutId = setTimeout(function() {self.doEventLoop()}, this.eventLoopRateMs);
    },
    stopEventLoop : function() {
        this.log("Stopping event loop");
        if(this.oldBrowser === true) {
            return;
        }

        clearTimeout(this.eventLoopTimeoutId);
    },
    documentBlur : function() {
        this.log("Document Blur");
        if(this.twoClickEventTimeoutId !== null) {
            clearTimeout(this.twoClickEventTimeoutId);
        }
        if(this.activeFrameIndex != -1 && this.activeFrameIndex == this.currentFrameIndex) {
            this.ezAwesomeClick(false, this.activeFrameIndex);
        }
    },
    fixedWindowBlur : function() {
        this.log("Fixed Window Blur");
        this.activeFrameIndex = this.searchFrames(document.activeElement);

        if(this.activeFrameIndex < 0) {
            this.activeFrame = null;
            return;
        }

        this.activeFrame = this.frameElements[this.activeFrameIndex];
        var self = this;
        var frameIndex = this.activeFrameIndex;

        this.twoClickEventTimeoutId = setTimeout(function() {
            self.ezAwesomeClick(true, frameIndex);
        }, this.clickTimeoutMs);
    },
    searchFrames : function(frameToFind) {
        for(var i = 0; i < this.frameElements.length; i++) {
            if (this.frameElements[i] === frameToFind || this.frameElements[i].contains(frameToFind)) {
                return i;
            }
        }
        return -1;
    },
    findParentsWithClass : function(elem, classNameList) {
        var parent = elem.parentNode;
        do {
            var classes = parent.className.split(/\s+/);
            for(var i = 0; i < classes.length; i++) {
                for(var j = 0; j < classNameList.length; j++) {
                    if(classes[i] == classNameList[j]) {
                        return parent;
                    }
                }
            }
        } while((parent = parent.parentNode) && this.isUndefined(parent.className) == false);

        return false;
    },
    ezAwesomeClick : function(isTwoClick, frameIndex) {
        this.log("EzAwesomeClick isTwoClick : ", isTwoClick, " and frame index : ", frameIndex);
        this.log(this.frameElements);
        var frameElem = this.frameElements[frameIndex];
        var data = this.frameData[frameIndex];
        var statSourceId = 0;
        if(typeof data != 'undefined') {
            statSourceId = data.statSourceId;
        }

        var adUnitName = this.getAdUnitFromElement(frameElem, statSourceId);

        this.log("adUnitName is: ",adUnitName);

        var paramsObj = null;
        if(adUnitName != "") {
            paramsObj = _ezim_d[adUnitName];
        } else {
            paramsObj = {
                position_id : 0,
                sub_position_id : 0,
                full_id : "0",
                width: 0,
                height: 0
            };
        }

        // For dfp ads, check if this is ox or adsense
        if(statSourceId == 2) {
            var iframes = frameElem.querySelectorAll("iframe");
            if(iframes.length > 0 && iframes[0].id.substring(0,3) == "ox_") {
                statSourceId = 33;
            } else {
                statSourceId = 5;
            }
        }

        if(this.isUndefined(window._ezaq) === true) {
            this.log("_ezaq not defined");
            return;
        }

        // check if clicks have been recorded for this element -- only save one two-click and up to 5 normal clicks
        if(isTwoClick === true) {
            data.twoClickRecorded = true;
        } else {
            // Save to sqs
            document.cookie = "ezoawesome_" + _ezaq.domain_id + "=" + statSourceId + "; path=/;";

            if(data.navigationsRecorded >= 5) {
                return;
            }

            data.navigationsRecorded += 1;
        }

        if(this.isUndefined(window.ezoTemplate) === true ||
            ezoTemplate === "pub_site_noads" ||
            ezoTemplate === "pub_site_mobile_noads" ||
            ezoTemplate === "pub_site_tablet_noads") {
            this.log("no click ezoTemplate is : ", ezoTemplate);
            return;
        }

        if (isTwoClick === false) {
            this.clickRequest("/utilcave_com/awesome.php", {
                url : _ezaq.url,
                width : paramsObj.width,
                height : paramsObj.height,
                did : _ezaq.domain_id,
                sourceid : statSourceId,
                uid : _ezaq.user_id,
                template : ezoTemplate
            });
        }

        this.clickRequest("/ezoic_awesome/", {
            url : _ezaq.url,
            width : paramsObj.width,
            height : paramsObj.height,
            did : _ezaq.domain_id,
            sourceid : statSourceId,
            uid : _ezaq.user_id,
            ff : _ezaq.form_factor_id,
            tid : _ezaq.template_id,
            apid : paramsObj.position_id,
            sapid : paramsObj.sub_position_id,
            iuid : paramsObj.full_id,
            creative : (this.isUndefined(paramsObj.creative_id) === false ? paramsObj.creative_id : ""),
            template : ezoTemplate,
            country : _ezaq.country,
            sub_ad_positions : _ezaq.sub_page_ad_positions,
            twoclick : (isTwoClick === true ? 1 : 0),
            max_ads : _ezaq.max_ads,
            word_count : _ezaq.word_count,
            user_agent : _ezaq.user_agent
        });
    },
    clickRequest : function(url, data) {
        this.log("Click Request with url : ", url, " and data : ", data);
        if((this.isUndefined(window.ezJsu) === false && ezJsu === true)
            || (this.isUndefined(window._ez_sa) === false && _ez_sa === true)) {
            url = "//g.ezoic.net" + url;
        } else {
            url = window.location.protocol + "//" + window.location.host + url;
        }

        var request = new XMLHttpRequest();
        var request_type = true;

        // Make request async on desktop and synchronous on mobile/tablet
        if(this.isMobileOperatingSystem() === true ) {
            request_type = false;
        }

        request.open('POST', url, request_type);
        request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
        var queryData = [];
        for(var param in data) {
            queryData.push(param + "=" + encodeURIComponent(data[param]));
        }
        request.send(queryData.join("&"));
    },
    getAdUnitFromElement : function(elem, statSourceId) {
        if(this.isUndefined(window._ezim_d) === true) {
            this.log("_ezim_d not found");
            return "";
        }

        if(statSourceId == 4) {
            for(key in _ezim_d) {
                if(key.indexOf("inline-1") != -1) {
                    this.log("found inline");
                    return key;
                }
            }
        } else if (statSourceId == 37 || statSourceId == 41) {
            var widgetWrapParent = this.findParentsWithClass(elem, ["ezoic-ad"]);
            if(widgetWrapParent !== false) {
                var adId = widgetWrapParent.className.replace("ezoic-ad", "").replace(/^\s+|\s+$/g, '');

                for (var key in _ezim_d) {
                    if(key.indexOf(adId) != -1) {
                        this.log("found native");
                        return key;
                    }
                }
            }
        } else if (this.isUndefined(elem.adunitname) === false) {
            this.log("found ad unit from elem.adunitname field");
            return elem.adunitname;
        } else if (elem.getAttribute('adunitname') != null) {
            this.log("found ad unit from property field: ",elem.getAttribute('adunitname'));
            return elem.getAttribute('adunitname');
        } else {
            for (key in _ezim_d) {
                if(elem.id.indexOf(key) != -1) {
                    this.log("found on _ezim_d");
                    return key;
                }
            }
        }

        return "";
    },
    attachWindowEvents : function() {
        this.log("Attaching window events");
        var self = this;
        this.windowBlurFunc = function() {
            self.log("Window Blur Func");
            self.windowHasFocus = false;

            if(self.lastActiveElement !== document.activeElement && self.oldBrowser === false) {
                self.fixedWindowBlur();
                self.lastActiveElement = document.activeElement;
            } else if (self.currentFrame !== null) {
                self.ezAwesomeClick(false, self.currentFrameIndex);
            }
        };

        this.windowFocusFunc = function() {
            self.log("Window Focus Func");
            self.windowHasFocus = true;
            self.activeFrame = null;
            self.activeFrameIndex = -1;
        };

        this.windowBeforeUnloadFunc = function() {
            self.log("Window Before Unload Func");
            if(self.twoClickEventTimeoutId !== null) {
                clearTimeout(self.twoClickEventTimeoutId);
            }

            // We don't have some events being called
            // We can account for that here
            if( self.isMobileOperatingSystem() ) {
                self.fixedWindowBlur();
            }

            if(self.currentFrameIndex != -1
                && self.activeFrameIndex == self.currentFrameIndex
                && self.frameData[self.activeFrameIndex].navigationsRecorded == 0) {
                self.ezAwesomeClick(false, self.activeFrameIndex);
            }
        };

        ez_attachEvent(window, "blur", this.windowBlurFunc);
        ez_attachEvent(window, "focus", this.windowFocusFunc);
        ez_attachEvent(window, "beforeunload", this.windowBeforeUnloadFunc);

        if(this.isIosUserAgent() === true) {
            this.log("Attaching pagehide");
            ez_attachEvent(window, "pagehide", this.windowBeforeUnloadFunc);
        }
    },
    detachWindowEvents : function() {
        this.log("Detaching window events.");
        ez_detachEvent(window, "blur", this.windowBlurFunc);
        ez_detachEvent(window, "focus", this.windowFocusFunc);
        ez_detachEvent(window, "beforeunload", this.windowBeforeUnloadFunc);

        if(this.isIosUserAgent() === true) {
            ez_detachEvent(window, "pagehide", this.windowBeforeUnloadFunc);
        }
    },
    isUndefined : function() {
        for (var i = 0; i < arguments.length; i++) {
            if (typeof arguments[i] === 'undefined' || arguments[i] === null) {
                return true;
            }
        }
        return false;
    },
    log : function() {
        if(this.DEBUG) {
            console.log.apply(console, arguments);
        }
    },
    isMobileOperatingSystem : function() {
        return typeof ezoFormfactor !== "undefined" && (ezoFormfactor == "2" || ezoFormfactor == "3");
    },
    isIosUserAgent : function() {
        return navigator.userAgent.indexOf("iPad") != -1 ||
            navigator.userAgent.indexOf("iPhone") != -1 ||
            navigator.userAgent.indexOf("iPod") != -1;
    }
};
ct.init();

var isCtrl = false;

document.onkeyup=function(e)
{
    if(e.which == 17) isCtrl=false;
    if(e.which == 18) isAlt=false;
}

document.addEventListener("keydown", function(e)
{
    if(e.which == 17) isCtrl=true;
    if(e.which == 18) isAlt=true;
    if(e.which == 69 && isCtrl == true && isAlt == true)
    {

        // if bar already exists, close it
        if($ezJQuery('#ezoic-bar-overlay').length)
        {
            $ezJQuery('#ezoic-bar-overlay').slideDown('slow').remove();
        }
        else
        {
            init_ez_bar();
        }

    }
}, true);

//document.onkeydown=function(e)
//{
//    if(e.which == 17) isCtrl=true;
//    if(e.which == 18) isAlt=true;
//    if(e.which == 69 && isCtrl == true && isAlt == true)
//    {
//
//        // if bar already exists, close it
//        if($ezJQuery('#ezoic-bar-overlay').length)
//        {
//            $ezJQuery('#ezoic-bar-overlay').slideDown('slow').remove();
//        }
//        else
//        {
//            init_ez_bar();
//        }
//
//    }
//}

function ez_force_recache()
{
    var url = document.URL;

    //create a form object
    var form = document.createElement("form");
    form.setAttribute("id", "force_recache");
    form.setAttribute("method", "POST");
    form.setAttribute("action", url);

    //create hidden field
    var hiddenField = document.createElement("input");
    hiddenField.setAttribute("type", "hidden");
    hiddenField.setAttribute("name", "ez_force_recache");
    hiddenField.setAttribute("value", "force_recache");
    form.appendChild(hiddenField);

    //inject form and submit it
    document.body.appendChild(form);
    form.submit();
}

    function init_ez_bar() {

    // If overlay already exists, remove it
    var ezOverlay = $ezJQuery('#ezoic-overlay');
    if ($ezJQuery(ezOverlay.length)) {
    $ezJQuery(ezOverlay).remove();
    }

    // Add Open Sans web font to document head
    $ezJQuery('head').append("<link href='//fonts.googleapis.com/css?family=Open+Sans:400,700' rel='stylesheet' type='text/css'>");

    if (document.cookie.indexOf("ezoic_show_disable_ads") >= 0) {
        var disable_link = "<li><a href=\"#\" class=\"js-ez-enable-ad-positions\">Hide \"Disable this ad position\" placeholders.</a></li>";
    } else {
        var disable_link = "<li><a href=\"#\" class=\"js-ez-disable-ad-positions\">Disable Ad Positions</a></li>";
    }

    // Create the overlay element
    var overlay = $ezJQuery('<div id="ezoic-bar-overlay">' +
    '<div id="ezoic-bar-container">' +
        '<div id="ezoic-bar-logo"><a href="http://ezoic.com" target="_ezoic"><img src="http://www.ezoic.com/assets/img/ezoic.png" alt="Ezoic"></a></div>' +
        '<ul id="ezoic-bar-actions">' +
            '<li><a href="#" class="js-ez-force-recache">Clear Cache</a></li>' +
            disable_link +
            '</ul>' +
        '<a href="#" id="ezoic-bar-close">Close this window</a>' +
        '</div>' +
    '</div>');

        // Append it to the body
        $ezJQuery(overlay).appendTo('body');

        // Style for ezoic overlay
        overlay.css({
        'fontFamily': 'Open Sans',
        'position': 'fixed',
        'bottom': '0px',
        'left': '0px',
        'height': '50px',
        'width': '100%',
        'z-index': '1000000',
        'backgroundColor': 'rgba(255, 255, 255, 0.9)',
        'border-top': '1px solid #eeeeee',
        'box-shadow': '0px 2px 2px -2px rgba(0, 0, 0, 0.25)',
        'text-shadow': '0 -1px 0 rgba(0, 0, 0, 0.25)'
        });

        $ezJQuery('#ezoic-bar-overlay a').css({
        'color': '#444444',
        'fontFamily': 'Open Sans',
        'text-shadow': '0 -1px 0 rgba(0, 0, 0, 0.25)'
        });

        $ezJQuery('#ezoic-bar-container').css({
        'max-width': 'none',
        'width': '100%'
        });

        $ezJQuery('ul#ezoic-bar-actions').css({
        'float': 'left',
        'height': '50px',
        'line-height': '50px',
        'list-style': 'none',
        'margin': '0px',
        'max-width': 'none',
        'padding': '0px'
        });

        $ezJQuery('#ezoic-bar-actions li').css({
        'display': 'inline',
        'font-size': '14px',
        'padding-left': '0px'
        });

        $ezJQuery('#ezoic-bar-actions li a').css({
        'color': '#444444',
        'font-size': '14px',
        'height': '50px',
        'line-height': '50px',
        'padding-left': '15px',
        'padding-right': '15px',
        'text-align': 'center',
        'text-decoration': 'none'
        })
        .hover(
        function() {
        $ezJQuery(this).css('color', '#888888');
        },
        function() {
        $ezJQuery(this).css('color', '#444444');
        }
        );

        $ezJQuery('#ezoic-bar-logo').css({
        'color': '#444444',
        'float': 'left',
        'font-weight': '700',
        'padding-left': '20px',
        'padding-right': '20px',
        'padding-top': '12px'
        });

        $ezJQuery('#ezoic-bar-logo img').css({
        'max-height': '26px'
        });

        // Close ezoic window on click
        $ezJQuery('#ezoic-bar-close')
        .on('click', function (e) {
        e.preventDefault();
        $ezJQuery('#ezoic-bar-overlay').remove();
        })
        .css({
        'float': 'right',
        'line-height': '50px',
        'padding': '0 20px',
        'color': '#444444'
        });

        // trigger recache
        $ezJQuery('.js-ez-force-recache')
        .on('click', function (e) {
        e.preventDefault();
        var self = $ezJQuery(this);
        var text = self.text();
        self.text('Clearing cache...');

        ez_force_recache();
        });

        $ezJQuery('.js-ez-disable-ad-positions')
        .on('click', function (e) {
        e.preventDefault();
        var self = $ezJQuery(this);
        var text = self.text();
        self.text('Authorizing...');

        window.location.replace("http://" + window.location.host + "/utilcave_com/auth.php?enable_ad_placeholders=1&rurl=" + encodeURIComponent(window.location.href) + "&did="+did);
        });

        $ezJQuery('.js-ez-enable-ad-positions')
        .on('click', function (e) {
        e.preventDefault();
        var self = $ezJQuery(this);
        var text = self.text();
        self.text('Refreshing...');

        window.location.replace("http://" + window.location.host + "/utilcave_com/auth.php?disable_ad_placeholders=1&rurl=" + encodeURIComponent(window.location.href));
        });

            // trigger hide template
            $ezJQuery('.js-ez-hide-template')
            .on('click', function (e) {
            e.preventDefault();
            var self = $ezJQuery(this);
            var text = self.text();
            self.text('Saving preference...');

            $ezJQuery.ajax({
                url: '/ezoic_ajax/hide_template.php',
                data: { ezdomain: ezdomain },
                success: function(data) {
                self.text(text);
                ez_force_recache();
                }
            });
        });
    }

    if(typeof execute_ez_queue == "function")
{
    if(typeof $ezJQuery != 'undefined')
    {
        $ezJQuery(window).load(function(){execute_ez_queue()});
    }
    else
    {
        window.onload=execute_ez_queue;
    }
}



 if(typeof $ezJQuery != 'undefined')
 {

}

if(typeof $ezJQuery != 'undefined' && typeof(__JASS) !== 'undefined') {
    (function(){var t=[].indexOf||function(t){for(var e=0,n=this.length;n>e;e++)if(e in this&&this[e]===t)return e;return-1},e=[].slice;!function(t,e){return"function"==typeof define&&define.amd?define("waypoints",["jquery"],function(){return e($ezJQuery,t)}):e($ezJQuery,t)}(window,function(n,r){var i,o,l,s,a,c,u,f,h,d,p,y,v,w,g,m;return i=n(r),f=t.call(r,"ontouchstart")>=0,s={horizontal:{},vertical:{}},a=1,u={},c="waypoints-context-id",p="resize.waypoints",y="scroll.waypoints",v=1,w="waypoints-waypoint-ids",g="waypoint",m="waypoints",o=function(){function t(t){var e=this;this.$element=t,this.element=t[0],this.didResize=!1,this.didScroll=!1,this.id="context"+a++,this.oldScroll={x:t.scrollLeft(),y:t.scrollTop()},this.waypoints={horizontal:{},vertical:{}},this.element[c]=this.id,u[this.id]=this,t.bind(y,function(){var t;return e.didScroll||f?void 0:(e.didScroll=!0,t=function(){return e.doScroll(),e.didScroll=!1},r.setTimeout(t,n[m].settings.scrollThrottle))}),t.bind(p,function(){var t;return e.didResize?void 0:(e.didResize=!0,t=function(){return n[m]("refresh"),e.didResize=!1},r.setTimeout(t,n[m].settings.resizeThrottle))})}return t.prototype.doScroll=function(){var t,e=this;return t={horizontal:{newScroll:this.$element.scrollLeft(),oldScroll:this.oldScroll.x,forward:"right",backward:"left"},vertical:{newScroll:this.$element.scrollTop(),oldScroll:this.oldScroll.y,forward:"down",backward:"up"}},!f||t.vertical.oldScroll&&t.vertical.newScroll||n[m]("refresh"),n.each(t,function(t,r){var i,o,l;return l=[],o=r.newScroll>r.oldScroll,i=o?r.forward:r.backward,n.each(e.waypoints[t],function(t,e){var n,i;return r.oldScroll<(n=e.offset)&&n<=r.newScroll?l.push(e):r.newScroll<(i=e.offset)&&i<=r.oldScroll?l.push(e):void 0}),l.sort(function(t,e){return t.offset-e.offset}),o||l.reverse(),n.each(l,function(t,e){return e.options.continuous||t===l.length-1?e.trigger([i]):void 0})}),this.oldScroll={x:t.horizontal.newScroll,y:t.vertical.newScroll}},t.prototype.refresh=function(){var t,e,r,i=this;return r=n.isWindow(this.element),e=this.$element.offset(),this.doScroll(),t={horizontal:{contextOffset:r?0:e.left,contextScroll:r?0:this.oldScroll.x,contextDimension:this.$element.width(),oldScroll:this.oldScroll.x,forward:"right",backward:"left",offsetProp:"left"},vertical:{contextOffset:r?0:e.top,contextScroll:r?0:this.oldScroll.y,contextDimension:r?n[m]("viewportHeight"):this.$element.height(),oldScroll:this.oldScroll.y,forward:"down",backward:"up",offsetProp:"top"}},n.each(t,function(t,e){return n.each(i.waypoints[t],function(t,r){var i,o,l,s,a;return i=r.options.offset,l=r.offset,o=n.isWindow(r.element)?0:r.$element.offset()[e.offsetProp],n.isFunction(i)?i=i.apply(r.element):"string"==typeof i&&(i=parseFloat(i),r.options.offset.indexOf("%")>-1&&(i=Math.ceil(e.contextDimension*i/100))),r.offset=o-e.contextOffset+e.contextScroll-i,r.options.onlyOnScroll&&null!=l||!r.enabled?void 0:null!==l&&l<(s=e.oldScroll)&&s<=r.offset?r.trigger([e.backward]):null!==l&&l>(a=e.oldScroll)&&a>=r.offset?r.trigger([e.forward]):null===l&&e.oldScroll>=r.offset?r.trigger([e.forward]):void 0})})},t.prototype.checkEmpty=function(){return n.isEmptyObject(this.waypoints.horizontal)&&n.isEmptyObject(this.waypoints.vertical)?(this.$element.unbind([p,y].join(" ")),delete u[this.id]):void 0},t}(),l=function(){function t(t,e,r){var i,o;"bottom-in-view"===r.offset&&(r.offset=function(){var t;return t=n[m]("viewportHeight"),n.isWindow(e.element)||(t=e.$element.height()),t-n(this).outerHeight()}),this.$element=t,this.element=t[0],this.axis=r.horizontal?"horizontal":"vertical",this.callback=r.handler,this.context=e,this.enabled=r.enabled,this.id="waypoints"+v++,this.offset=null,this.options=r,e.waypoints[this.axis][this.id]=this,s[this.axis][this.id]=this,i=null!=(o=this.element[w])?o:[],i.push(this.id),this.element[w]=i}return t.prototype.trigger=function(t){return this.enabled?(null!=this.callback&&this.callback.apply(this.element,t),this.options.triggerOnce?this.destroy():void 0):void 0},t.prototype.disable=function(){return this.enabled=!1},t.prototype.enable=function(){return this.context.refresh(),this.enabled=!0},t.prototype.destroy=function(){return delete s[this.axis][this.id],delete this.context.waypoints[this.axis][this.id],this.context.checkEmpty()},t.getWaypointsByElement=function(t){var e,r;return(r=t[w])?(e=n.extend({},s.horizontal,s.vertical),n.map(r,function(t){return e[t]})):[]},t}(),d={init:function(t,e){var r;return e=n.extend({},n.fn[g].defaults,e),null==(r=e.handler)&&(e.handler=t),this.each(function(){var t,r,i,s;return t=n(this),i=null!=(s=e.context)?s:n.fn[g].defaults.context,n.isWindow(i)||(i=t.closest(i)),i=n(i),r=u[i[0][c]],r||(r=new o(i)),new l(t,r,e)}),n[m]("refresh"),this},disable:function(){return d._invoke.call(this,"disable")},enable:function(){return d._invoke.call(this,"enable")},destroy:function(){return d._invoke.call(this,"destroy")},prev:function(t,e){return d._traverse.call(this,t,e,function(t,e,n){return e>0?t.push(n[e-1]):void 0})},next:function(t,e){return d._traverse.call(this,t,e,function(t,e,n){return e<n.length-1?t.push(n[e+1]):void 0})},_traverse:function(t,e,i){var o,l;return null==t&&(t="vertical"),null==e&&(e=r),l=h.aggregate(e),o=[],this.each(function(){var e;return e=n.inArray(this,l[t]),i(o,e,l[t])}),this.pushStack(o)},_invoke:function(t){return this.each(function(){var e;return e=l.getWaypointsByElement(this),n.each(e,function(e,n){return n[t](),!0})}),this}},n.fn[g]=function(){var t,r;return r=arguments[0],t=2<=arguments.length?e.call(arguments,1):[],d[r]?d[r].apply(this,t):n.isFunction(r)?d.init.apply(this,arguments):n.isPlainObject(r)?d.init.apply(this,[null,r]):n.error(r?"The "+r+" method does not exist in jQuery Waypoints.":"jQuery Waypoints needs a callback function or handler option.")},n.fn[g].defaults={context:r,continuous:!0,enabled:!0,horizontal:!1,offset:0,triggerOnce:!1},h={refresh:function(){return n.each(u,function(t,e){return e.refresh()})},viewportHeight:function(){var t;return null!=(t=r.innerHeight)?t:i.height()},aggregate:function(t){var e,r,i;return e=s,t&&(e=null!=(i=u[n(t)[0][c]])?i.waypoints:void 0),e?(r={horizontal:[],vertical:[]},n.each(r,function(t,i){return n.each(e[t],function(t,e){return i.push(e)}),i.sort(function(t,e){return t.offset-e.offset}),r[t]=n.map(i,function(t){return t.element}),r[t]=n.unique(r[t])}),r):[]},above:function(t){return null==t&&(t=r),h._filter(t,"vertical",function(t,e){return e.offset<=t.oldScroll.y})},below:function(t){return null==t&&(t=r),h._filter(t,"vertical",function(t,e){return e.offset>t.oldScroll.y})},left:function(t){return null==t&&(t=r),h._filter(t,"horizontal",function(t,e){return e.offset<=t.oldScroll.x})},right:function(t){return null==t&&(t=r),h._filter(t,"horizontal",function(t,e){return e.offset>t.oldScroll.x})},enable:function(){return h._invoke("enable")},disable:function(){return h._invoke("disable")},destroy:function(){return h._invoke("destroy")},extendFn:function(t,e){return d[t]=e},_invoke:function(t){var e;return e=n.extend({},s.vertical,s.horizontal),n.each(e,function(e,n){return n[t](),!0})},_filter:function(t,e,r){var i,o;return(i=u[n(t)[0][c]])?(o=[],n.each(i.waypoints[e],function(t,e){return r(i,e)?o.push(e):void 0}),o.sort(function(t,e){return t.offset-e.offset}),n.map(o,function(t){return t.element})):[]}},n[m]=function(){var t,n;return n=arguments[0],t=2<=arguments.length?e.call(arguments,1):[],h[n]?h[n].apply(null,t):h.aggregate.call(null,n)},n[m].settings={resizeThrottle:100,scrollThrottle:30},i.on("load.waypoints",function(){return n[m]("refresh")})})}).call(this),function(){!function(t,e){return"function"==typeof define&&define.amd?define(["jquery","waypoints"],e):e($ezJQuery)}(window,function(t){var e,n;return e={wrapper:'<div class="sticky-wrapper" />',stuckClass:"stuck",direction:"down right"},n=function(t,e){var n;return t.wrap(e.wrapper),n=t.parent(),n.data("isWaypointStickyWrapper",!0)},t.waypoints("extendFn","sticky",function(r){var i,o,l;return o=t.extend({},t.fn.waypoint.defaults,e,r),i=n(this,o),l=o.handler,o.handler=function(e){var n,r;return n=t(this).children(":first"),r=-1!==o.direction.indexOf(e),n.toggleClass(o.stuckClass,r),i.height(r?n.outerHeight():""),null!=l?l.call(this,e):void 0},i.waypoint(o),this.data("stuckClass",o.stuckClass)}),t.waypoints("extendFn","unsticky",function(){var t;return t=this.parent(),t.data("isWaypointStickyWrapper")?(t.waypoint("destroy"),this.unwrap(),this.removeClass(this.data("stuckClass"))):this})})}.call(this);
    var ezStickyHeightEl = $ezJQuery('#stylesheet_body');
    var ezStickyCurrentHeight = ezStickyHeightEl.height();
    var ezSidebarHeightEl = $ezJQuery('.ezSidebar');
    var ezSidebarCurrentHeight = ezSidebarHeightEl.height();
    var stickyElement = function (stickyAdPosition) {
        var $stickyEl = $ezJQuery("#ez-sticky-ad-"+stickyAdPosition);
        var $stopEl = $ezJQuery('.ezoic-sticky-cutoff');
        var stickyElExtraOffset = ezGetTopPositionForAd($stickyEl);
        $stopEl.waypoint(function (direction) {
            if (direction == 'down') {
                var footerOffset = $stopEl.offset();
                $stickyEl.css({
                    position: 'absolute',
                    top: footerOffset.top - stickyElExtraOffset - $stickyEl.outerHeight()
                });
            } else if (direction == 'up') {
                $stickyEl.attr('style', '');
            }
        }, { offset: function () { return $stickyEl.outerHeight(); }});
        $stickyEl.waypoint('sticky', {
            wrapper: '<div class="ez-sticky-wrapper" />',
            stuckClass: 'ez-sticky-class',
            offset: -1
        });
    };
    var ezGetTopPositionForAd = function(el) {
        var stickyElExtraTop = 0;
        if (el.offsetParent()) {
            el = el.offsetParent();
            var maxLoops = 10;
            var currentLoop = 1;
            do {
                stickyElExtraTop += el.offset().top;
                currentLoop++;
                if (currentLoop > maxLoops || el.prop('tagName') == 'HTML') break;
            } while (el = el.offsetParent());
        }
        return stickyElExtraTop;
    };
    var ezCheckWayRefresh = function () {
        var changed = false;
        var height = ezStickyHeightEl.height();
        var sidebarHeight = ezSidebarHeightEl.height();
        if (height != ezStickyCurrentHeight) {
            ezStickyCurrentHeight = height;
            changed = true;
        }
        if (sidebarHeight != ezSidebarCurrentHeight) {
            ezSidebarCurrentHeight = sidebarHeight;
            changed = true;
        }
        if (changed == true) {
            $ezJQuery.waypoints('refresh');
        }
    };
    __JASS.onWindowLoad(function() {
        if (!!$ezJQuery('#ez-sticky-ad-1').length && !$ezJQuery('#ez-sticky-ad-1').is(':empty')) {
            if ($ezJQuery(".ezoic-sticky-cutoff").offset().top > ($ezJQuery("#ez-sticky-ad-1").offset().top + $ezJQuery('#ez-sticky-ad-1').height())) {
                stickyElement(1);
                $ezJQuery(window).scroll(function() { ezCheckWayRefresh(); });
                window.setInterval(function(){ ezCheckWayRefresh(); }, 5000);
            }
        }
    });
}
