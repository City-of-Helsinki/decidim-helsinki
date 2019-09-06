((exports) => {
  // eslint-disable-next-line id-length
  const $ = exports.$;

  // This needs to be called for the body always when the page is reloaded
  // $('body').applyPolyfills();
  $.fn.applyPolyfills = function() {
    return $(this).each((_i, element) => {
      if (!exports.Modernizr.objectfit) {
        $("img.card__image", element).objectFitPolyfill();
      }
    });
  }

  $.fn.objectFitPolyfill = function() {
    return $(this).each((_i, element) => {
      const height = $(element).height(),
          imgUrl = $(element).prop("src");

      if (imgUrl) {
        const cls = $(element).prop("class");
        const $container = $("<div></div>");

        $container.prop("class", cls).css({
          backgroundImage: `url(${imgUrl})`,
          backgroundSize: "cover",
          backgroundPosition: "center center"
        }).addClass("compat-object-fit").height(height)
        ;

        $(element).replaceWith($container);
      }
    });
  };
})(window);
