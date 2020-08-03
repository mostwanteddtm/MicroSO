function languageChanged(langSelect) {                   
  var url = langSelect.value;
  if (url && url != "") {
    window.location = url;
  }
}

function imageEnchanter(enlargeText, lang, contextRoot){  
  $("#primarycontentcontainer img")
  .load(function(){
    var originalWidth = $(this).width();
    var originalHeight = $(this).height();
    //console.log('height: ' + originalHeight);
    //console.log('width: ' + originalWidth);
    if(originalWidth > 740){
      var newHeight = Math.round(originalHeight / (originalWidth / 740));
      //console.log('newHeight: ' + newHeight);
      imgUrl = "<a onclick=\"window.open('/" + contextRoot + "/app/largeimage?lang=" + lang + "&imageurl=" + encodeURIComponent($(this).attr("src")) + "','awindow','scrollbars=yes, resizable=yes');return false;\" href=\"#\"";
      $(this).width("740px");
      $(this).height(newHeight + "px");
      $(this).wrap(imgUrl + " />");
      $(this).parent().after("<span class=\"no-print wp-enlarge-link\">" + imgUrl + "><br/>" + enlargeText + "</a></span>\n");
    }
    return false; // cancel event bubble
  })
  .each(function(){
    // trigger events for images that have loaded,
    // other images will trigger the event once they load
    if ( this.complete && this.naturalWidth !== 0 ) {
      $( this ).trigger('load');
    }
  });
}

//toggles "more reviews" and changes text of link when "View more reviews" link is clicked
$(document).ready(function() {
	$('.review_toggle').toggle
		(function(e) {
			e.preventDefault();
			$('.review_hide').toggle('.review_hide');
			$(this).html("View less reviews");
		},
		function(e){
			e.preventDefault();
			$('.review_hide').toggle('.review_hide');
			$(this).html("View more reviews");
	}); 
});