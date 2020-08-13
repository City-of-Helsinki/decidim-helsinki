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
            breakpoint: 768,
            settings: {
              arrows: false,
              centerMode: true,
              centerPadding: "40px",
              slidesToShow: 3
            }
          },
          {
            breakpoint: 480,
            settings: {
              arrows: false,
              centerMode: true,
              centerPadding: "40px",
              slidesToShow: 1
            }
          }
        ]
      });
    });
  }
})(window);
