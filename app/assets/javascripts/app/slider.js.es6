// = require slick
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  $.fn.slider = function() {
    return $(this).each((_i, element) => {
      const $slider = $(element);
      const prevLabel = $slider.data("prev-label");
      const nextLabel = $slider.data("next-label");

      let config = {
        prevArrow: `<button class="slick-prev" aria-label="${prevLabel}" type="button">${prevLabel}</button>`,
        nextArrow: `<button class="slick-next" aria-label="${nextLabel}" type="button">${nextLabel}</button>`,
        dots: true,
        adaptiveHeight: true
      };
      if ($slider.hasClass("single")) {
        config = $.extend(config, {
          slidesToShow: 1,
        });
      } else { // center
        config = $.extend(config, {
          centerMode: true,
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
      }

      $slider.on("init", () => {
        // When the dot is changed from the keyboard, update the focused dot.
        const $dots = $(".slick-dots", $slider);
        $dots.on("keydown", (ev) => {
          if ($("button:focus", $dots).length < 1) {
            return;
          }

          // 37 = left arrow, 39 = right arrow
          if (ev.keyCode !== 37 && ev.keyCode !== 39) {
            return;
          }

          $(".slick-active button", $dots).focus();
        });
      }).slick(config);
    });
  }
})(window);
