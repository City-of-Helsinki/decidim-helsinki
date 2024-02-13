// This file is compiled inside Decidim core pack. Code can be added here and will be executed
// as part of that pack

import initHeader from "src/helsinki/header";
import fixMap from "src/helsinki/fix_map";
import "src/helsinki/toggle_checkbox";
import initSlider from "src/helsinki/slider";
import "src/helsinki/youtube_modal";

// Load images
require.context("../../images", true);

const initialize = (container) => {
  initSlider(container);

  $("[data-toggle-checkbox]", container).toggleCheckbox();
  $("[data-open-youtube]", container).youtubeModal();

  // Fix the hidden maps that are shown on toggles
  $(".tabs", container).on("change.zf.tabs", (el) => {
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

  $("#proposals-map-container", container).on("on.zf.toggler off.zf.toggler", (ev) => {
    fixMap(ev.target);
  });

  // Adds the class to the drilldown element parents indicating whether the
  // element is open or not. This helps to style the menu while it is open.
  $("[data-drilldown]", container).each((_i, el) => {
    const $parent = $(el).parents(".is-drilldown");
    if ($parent.length < 1) {
      return;
    }

    $(el).on("open.zf.drilldown", () => {
      $parent.addClass("is-open");
    });
    $(el).on("close.zf.drilldown", () => {
      $parent.removeClass("is-open");
    });
  });

  // Move the scroll position at the top of the accordion when it is opened if
  // it is outside of the current view.
  $(".accordion", container).each((_i, element) => {
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
};

$(() => {
  initHeader();

  initialize(document);

  $(".hide-on-load").removeClass("hide-on-load");

  document.addEventListener("section:update", (ev) => {
    initialize(ev.target);
  });

  // Event to determine when the application scripts have finished their setup
  $(document).trigger("app-ready");
});
