addToNamespace("NI.pnx").autocomplete =
{
  ///<signature externalid="NI.pnx">
  ///<param name="resultSize" type="NI.pnx.autocomplete.resultSize">Decides between number of results. Default: small</param>
  ///<param name="type" type="NI.pnx.autocomplete.type">Allows the developer to use one of our default data sources, or pass in their own. Default: global</param>
  ///<param name="initialize" type="Function">, or pass in their own. Default: global</param>
  ///</signature>
  resultSize :
  {
    small: 5,
    large: 7
  },
  type :
  {
    address: 'addressSearch',
    global: 'globalSearch',
    filtered: 'filteredSearch',
    custom: 'customSearch'
  },

  /**
   * @type Function
   * @param {Function} dataSource Optional method that returns a JSONP object of labels and values.
   * @param {Function} dataSource Optional method that returns a JSONP object of labels and values.
  **/
  initialize : function()
  {
    ///<signature externalid="NI.pnx.autocomplete">
    ///<param name="dataSource" type="Function">Optional method that returns a JSONP object of labels and values.</param>
    ///</signature>
    $(".niAutocompleteInput").each(function (i)
    {
      /* Defaults */
      var source, position;
      var niSearchType = (typeof($(this).data("search-type")) !== 'undefined') ? $(this).data("search-type") : 'default';
      var resultsClass = 'default';
      var language = (typeof($.cookie("locale"))!== 'undefined')?$.cookie("locale"):'en';
      if (language.substring(0,2)=="zh")
      {
       if (language == "zh-CN") language = "zhs";
       if (language == "zh-TW" || language == "zh-HK") language = "zht";
      }
      language = language.replace(/\-.*/, "");
 
      $.ajaxSetup({'cache':true});
      
      if (niSearchType == NI.pnx.autocomplete.type.global){
        resultsClass = 'global-dropdown';
        position = { my : 'left top', at: 'left-25% bottom', colision: 'none' };
        source = function (request, response)
        {
          $.ajax({
            url:"//flux.ni.com/search-rest/2/sitewideautocomplete.jsonp",
            data: {
              "ni-api-key": "nisearch",
              query: request.term,
              maxscenariohits: 0,
              maxqueryhits: NI.pnx.autocomplete.resultSize.large,
              scenario: 'global',
              lang: language
            },
            dataType: "jsonp",
            success: function(data) {
              var indx = -1, indx_set = false;
              $.each(data, function(index, value){
                if(value.section !== data[0].section && indx_set === false){
                  indx = index;
                  indx_set = true;
                }
              });
              response($.map(data, function(item, i){
                var myMassagedReturn = { i: i, separator: indx, searchType: resultsClass };
                $.each(item, function(key, value){
                    myMassagedReturn[key] = value;
                });
                return myMassagedReturn;  
              }));
            }
          });
        };
      }
      else if (niSearchType == NI.pnx.autocomplete.type.address) {

      }
      else if (niSearchType == NI.pnx.autocomplete.type.filtered) {
        resultsClass = 'default';
        position = { my: 'left top', at: 'left bottom', collision: 'none' };
        source = function (request, response)
        {
          var workingScenario = 'global';
          var checkedScenario = $(".searchFilterDropDown").data('scenario');
          if ((typeof(checkedScenario) !== 'undefined')&&(checkedScenario !== ''))
          {
            workingScenario = checkedScenario;
          }
          $.ajax({
            url:"//flux.ni.com/search-rest/2/sitewideautocomplete.jsonp",
            data: {
              "ni-api-key": "nisearch",
              query: request.term,
              maxscenariohits: 6,
              maxqueryhits: NI.pnx.autocomplete.resultSize.small,
              scenario: workingScenario,
              lang: language
            },
            dataType: "jsonp",
            success: function(data) {
              var indx = -1, indx_set = false;
              $.each(data, function(index, value){
                if(value.section !== data[0].section && indx_set === false){
                  indx = index;
                  indx_set = true;
                }
              });
              response($.map(data, function(item, i){
                var myMassagedReturn = { i: i, separator: indx, searchType: resultsClass };
                $.each(item, function(key, value){
                    myMassagedReturn[key] = value;
                });
                return myMassagedReturn;  
              }));
            }
          });
        };
      }
      else if (niSearchType == NI.pnx.autocomplete.type.custom) {
        var c_dataObj = {};
        var c_resultsAry = '';
        var c_resultsURL = '';
        resultsClass = 'default';
        position = { my: 'left top', at: 'left bottom', collision: 'none' };
        c_resultsAry = (typeof($(this).data("results-array")) !== 'undefined') ? $(this).data("results-array") : '';
        c_resultsURL = (typeof($(this).data("results-url")) !== 'undefined') ? $(this).data("results-url") : '';
        c_dataObj = (typeof($(this).data("data-obj")) !== 'undefined') ? $(this).data("data-obj") : {};
        c_resultsURL = eval(c_resultsURL);
        c_dataObj = eval(c_dataObj);
        if (c_resultsAry!=='') {
          source = eval(c_resultsAry).slice(0,NI.pnx.autocomplete.resultSize.large);
        }
        else if (c_resultsURL!=='')
        {
          source = function (request, response)
          {
            c_dataObj.query = request.term;
            c_dataObj.lang = language;
            c_dataObj.hits = NI.pnx.autocomplete.resultSize.small;
            $.ajax({
              url:c_resultsURL,
              data: c_dataObj,
              dataType: "jsonp",
              success: function(data) {
                var indx = -1, indx_set = false;
                $.each(data, function(index, value){
                  if(value.section !== data[0].section && indx_set === false){
                    indx = index;
                    indx_set = true;
                  }
                });
                
                response($.map(data, function(item, i){
                  var myMassagedReturn = { i: i, separator: indx, searchType: resultsClass };
                  $.each(item, function(key, value){
                      myMassagedReturn[key] = value;
                  });
                  return myMassagedReturn;
                }));
              }
            });
          };
        }
      }
      else {
        resultsClass = 'default';
        position = { my: 'left top', at: 'left bottom', collision: 'none' };
        source = function (request, response)
        {
          $.ajax({
            url:"//flux.ni.com/search-rest/2/sitewideautocomplete.jsonp",
            data: {
              "ni-api-key": "nisearch",
              query: request.term,
              maxscenariohits: 5,
              maxqueryhits: NI.pnx.autocomplete.resultSize.small,
              scenario: 'global',
              lang: language
            },
            dataType: "jsonp",
            success: function(data) {
              var indx = -1, indx_set = false;
              $.each(data, function(index, value){
                if(value.section !== data[0].section && indx_set === false){
                  indx = index;
                  indx_set = true;
                }
              });
              response($.map(data, function(item, i){
                var myMassagedReturn = { i: i, separator: indx, searchType: resultsClass };
                $.each(item, function(key, value){
                    myMassagedReturn[key] = value;
                });
                return myMassagedReturn;
              }));
            }
          });
        };
      }
      
      $(this).autocomplete({
        source: source,
        minLength: 3,
        delay: 333,
        position: position,
        appendTo: $(this).parent(),
        open: function( event, ui ) {
          try
          {
            $('.pnx-ellipsis').dotdotdot({
              height: 40,
              tollerance:0
            });
          }
          catch(e)
          {
            throw e+'\nPlease include "/widgets/pnx/1.0/js/jquery.dotdotdot.min.js" in your page.';
          }
        },
        select: function( event, ui ) {
          $(this).val(ui.item.value);
          var eventSubmitSearch = (event.target.getAttribute('data-search-submit') !== null) ? event.target.getAttribute('data-search-submit') : 'true';
          var bSubmitSearch = ( eventSubmitSearch === 'true');
          //following check, only needed on inline search pages
          var searchDD = $(".searchFilterDropDown");
          if ((ui.item.facetselection !== searchDD.data('initialfacet')) || (searchDD.data('facetselection') !== (searchDD.data('initialfacet'))))
          {
            $('input[name=sb]').val('');            
            $('input[name=fil]').val('');            
            $(this).closest("form").find("[name=sn]").val(ui.item.facetselection);
          }

          $.each(ui.item, function(key, value){
            if(key !== 'label')
            {
              var targetHiddenInput = ($(event.target).closest('form').find("'input[id="+key+"_"+event.target.id+"]'"));
              if($(targetHiddenInput).length <= 0)
              {
                $(event.target).after('<input type="hidden" id="'+ key +'_'+ event.target.id +'" name="'+ key +'_'+ event.target.id +'" value="'+ value.toString().replace(/(['"])/g, "\\$1") +'"/>\n');
              }
              else
              {
                $(targetHiddenInput).val(value.toString().replace(/(['"])/g, "\\$1"));
              }
            }
          });
          
          if (bSubmitSearch)
          {
            $(this).closest('form').submit();
          }
          return false;
        }
      }).data("ui-autocomplete");
      
      $.ui.autocomplete.prototype._renderItem = function (ul, item)
      {
        ul.addClass(item.searchType);  
        var li = $("<li></li>"), listitem = "";
        listitem += "<a data-scenario=\"" + item.scenario + "\"><div class=\"pnx-ellipsis\">";
        if (item.label !== '') {
          if (item.label.indexOf("<key>") === -1)
          {
            item.label = item.label.replaceAll(this.term,"<span class=\"ui-menu-item-label-highlight\">" + 
              this.term + "</span>");
            item.value = item.value.replaceAll("<span class=\"ui-menu-item-label-highlight\">", "").replaceAll("</span>","");
          }
          else
          {
            item.label = (item.label.replaceAll("<key>", "<span class=\"ui-menu-item-label-highlight\">")).replaceAll("</key>", "</span>");
            item.value = (item.value.replaceAll("<key>", "")).replaceAll("</key>", "");
          }
        }
        else
        {
          item.label = '<span class="scenario-spacer"></span>';
        }
        if(item.section === "scenario"){
          item.scenarioString = (item.scenarioString.replaceAll("<scn>", "<span class=\"ui-menu-item-scenario-highlight\">")).replaceAll("</scn>", "</span>");
        }													
        listitem += item.label;
        if (typeof(item.scenarioString) !== 'undefined') {
          listitem += ' ' + item.scenarioString;
        }
        listitem += "</div></a>";
        li.data("item.autocomplete", item).append(listitem).appendTo(ul);
        if(item.i + 1 === item.separator){
          li.css("border-bottom","1px solid #CCC");
        }
        
        return li;
      };
      //$.ui.autocomplete.prototype._renderMenu = function( ul, items ) {
      //    var self = this;
      //    var parentItem = '';
      //    $.each( items, function( index, item )
      //    {
      //      if (index<items.length-1)
      //      {
      //        if (item.label === items[index+1].label)
      //        {
      //          if (item.label !== '')
      //          {
      //            parentItem = item;
      //            var tempItem = $.extend(true, {}, item);
      //            tempItem.scenarioString = '';
      //            tempItem.facetselection = 'global';
      //            self._renderItem(ul, tempItem);
      //            item.label = '';
      //          }
      //          items[index+1].label = '';
      //        }
      //      }
      //
      //      self._renderItem( ul, item );
      //    });
      //};
    });
  }
  
};

