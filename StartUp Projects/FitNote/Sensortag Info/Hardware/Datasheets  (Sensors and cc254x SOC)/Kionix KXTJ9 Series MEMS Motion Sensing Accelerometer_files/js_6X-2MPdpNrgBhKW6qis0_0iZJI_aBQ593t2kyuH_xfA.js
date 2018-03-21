(function ($) {
	Drupal.behaviors.backtotop = {
		attach: function(context) {
			var exist= jQuery('#backtotop').length;
      if(exist == 0) {
        $("body").append("<div id='backtotop'>"+Drupal.t("Back to Top")+"</div>");
      }
			$(window).scroll(function() {
				if($(this).scrollTop() > Drupal.settings.back_to_top.back_to_top_button_trigger) {
					$('#backtotop').fadeIn();	
				} else {
					$('#backtotop').fadeOut();
				}
			});

			$('#backtotop').click(function() {
				$('body,html').animate({scrollTop:0},1200,'easeOutQuart');
			});	
		}
	};
})(jQuery);;
(function ($) {

$(function() {
  var googleCSEWatermark = function(id) {
    var f = $(id)[0];
    if (f && (f.query || f['edit-search-block-form--2'] || f['edit-keys'])) {
      var q = f.query ? f.query : (f['edit-search-block-form--2'] ? f['edit-search-block-form--2'] : f['edit-keys']);
      var n = navigator;
      var l = location;
      if (n.platform == 'Win32') {
        q.style.cssText = 'border: 1px solid #7e9db9; padding: 2px;';
      }
      var b = function() {
        if (q.value == '') {
          q.style.background = '#FFFFFF url(https://www.google.com/cse/intl/' + Drupal.settings.googleCSE.language + '/images/google_custom_search_watermark.gif) left no-repeat';
        }
      };
      var f = function() {
        q.style.background = '#ffffff';
      };
      q.onfocus = f;
      q.onblur = b;
//      if (!/[&?]query=[^&]/.test(l.search)) {
        b();
//      }
    }
  };
  googleCSEWatermark('#search-block-form.google-cse');
  googleCSEWatermark('#search-form.google-cse');
  googleCSEWatermark('#google-cse-results-searchbox-form');
});

})(jQuery);
;
