(function ($) {
  $(document).on('ready', function () {
    if (!Modernizr.objectfit) {
      $('img.card__image').each(function () {
        var imgUrl = $(this).prop('src'),
            height = $(this).height();

        if (imgUrl) {
          var $container = $('<div class="card__image"></div>');
          $container
            .css({
              backgroundImage: 'url(' + imgUrl + ')',
              backgroundSize: 'cover',
            })
            .addClass('compat-object-fit')
            .height(height)
          ;

          $(this).replaceWith($container);
        }
      });
    }
  })
})($)
