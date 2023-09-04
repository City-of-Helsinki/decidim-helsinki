// This file is compiled inside Decidim core pack. Code can be added here and will be executed
// as part of that pack

import initHeader from "src/helsinki/header";
import fixMap from "src/helsinki/fix_map";
import "src/helsinki/toggle_checkbox";
import initSlider from "src/helsinki/slider";
import "src/helsinki/youtube_modal";

// Load images
require.context("../../images", true);

$(() => {
  initHeader();
  initSlider();

  $("[data-toggle-checkbox]").toggleCheckbox();
  $("[data-open-youtube]").youtubeModal();

  // Fix the hidden maps that are shown on toggles
  $(".tabs").on("change.zf.tabs", (el) => {
    const tabsId = $(el.target).attr("id");
    const $content = $(`[data-tabs-content="${tabsId}"`);
    if (!$content || $content.length < 1) {
      return;
    }

    const $activePanel = $("> .is-active", $content);
    if ($activePanel.length > 0) {
      fixMap($activePanel[0])
    }
  });

  $("#proposals-map-container").on("on.zf.toggler off.zf.toggler", (ev) => {
    fixMap(ev.target);
  });

  // Adds the class to the drilldown element parents indicating whether the
  // element is open or not. This helps to style the menu while it is open.
  $("[data-drilldown]").each((_i, el) => {
    const $parent = $(el).parents(".is-drilldown");
    if ($parent.length < 1) {
      return;
    }

    $(el).on("open.zf.drilldown", () => {
      console.log("OPEN DRILLDOWN");
      $parent.addClass("is-open");
    });
    $(el).on("close.zf.drilldown", () => {
      console.log("CLOSE DRILLDOWN");
      $parent.removeClass("is-open");
    });
  });

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
});
