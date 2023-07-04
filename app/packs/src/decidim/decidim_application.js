// This file is compiled inside Decidim core pack. Code can be added here and will be executed
// as part of that pack

import "src/helsinki/fix_map_toggle";
import "src/helsinki/toggle_checkbox";
import "src/helsinki/slider";
import "src/helsinki/youtube_modal";

// Load images
require.context("../../images", true);

$(() => {
  $("#proposals-map-container").fixMapToggle();
  $("[data-toggle-checkbox]").toggleCheckbox();
  $("[data-open-youtube]").youtubeModal();
  $(".card-slider").slider();

  // Move the scroll position at the top of the accordion when it is opened if
  // it is outside of the current view.
  $(".accordion").each((_i, element) => {
    const $accordion = $(element);
    const accordionPlugin = $accordion.data("zfPlugin");
    let accordionTo = null;

    $(".accordion-item .accordion-title", $accordion).on("click", (ev) => {
      const $title = $(ev.target);
      const $item = $title.parents(".accordion-item");

      // Wait for the accordion to open
      clearTimeout(accordionTo);
      accordionTo = setTimeout(() => {
        const currentTop = $(window).scrollTop();
        const currentBottom = currentTop + window.innerHeight;
        const targetPos = $item.offset().top;

        if (targetPos < currentTop || targetPos > currentBottom) {
          $(window).scrollTop(targetPos);
        }
      }, accordionPlugin.options.slideSpeed + 50);
    })
  });

  $(".hide-on-load").removeClass("hide-on-load");

  // Event to determine when the application scripts have finished their setup
  $(document).trigger("app-ready");
})
