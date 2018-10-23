(function ($) {
  // This needs to be called for the body always when the page is reloaded
  // $('body').applyPolyfills();
  $.fn.applyPolyfills = function() {
    return $(this).each(function() {
      if (!Modernizr.objectfit) {
        $('img.card__image', this).objectFitPolyfill();
      }
    });
  }

  $.fn.objectFitPolyfill = function() {
    return $(this).each(function() {
      var imgUrl = $(this).prop('src'),
          height = $(this).height();

      if (imgUrl) {
        var cls = $(this).prop('class');
        var $container = $('<div></div>');

        $container
          .prop('class', cls)
          .css({
            backgroundImage: 'url(' + imgUrl + ')',
            backgroundSize: 'cover',
            backgroundPosition: 'center center',
          })
          .addClass('compat-object-fit')
          .height(height)
        ;

        $(this).replaceWith($container);
      }
    });
  };
})($);
