// = require slick
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  $.fn.slider = function() {
    return $(this).each((_i, element) => {
      $(element).slick({
        centerMode: true,
        dots: true,
        adaptiveHeight: true,
        centerPadding: 0,
        slidesToShow: 3,
        responsive: [
          {
            breakpoint: 1024,
            settings: {
              centerMode: false,
              centerPadding: "40px",
              slidesToShow: 2
            }
          },
          {
            breakpoint: 768,
            settings: {
              centerMode: false,
              centerPadding: "40px",
              slidesToShow: 1
            }
          }
        ]
      });
    });
  }
})(window);
