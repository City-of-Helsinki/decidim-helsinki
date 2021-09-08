// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
// = require jquery
// = require rails-ujs
// = require activestorage
// = require cable
// = require decidim
// = require ie-polyfills
// = require app/toggle-checkbox
// = require app/fix-map-toggle
// = require app/modal-accessibility
// = require app/remaining-characters
// = require app/youtube-modal
// = require app/slider
// = require_self

((exports) => {
  // eslint-disable-next-line id-length
  const $ = exports.$;

  $(() => {
    $("#proposals-map-container").fixMapToggle();
    $("[data-toggle-checkbox]").toggleCheckbox();
    $(".remaining-characters-container [data-remaining-characters]").remainingCharacters();
    $("[data-open-youtube]").youtubeModal();
    $(".card-slider").slider();
    $("a[data-open]").on("click", (ev) => {
      ev.preventDefault();
    });

    $(document).on("open.zf.reveal", (ev) => {
      const $modal = $(ev.target);
      $modal.modalAccessibility();

      if ($(".off-canvas-wrapper").hasClass("wrapper-ruuti")) {
        $modal.addClass("wrapper-ruuti");
      }
    });

    // Open process nav with enter
    const $processNavState = $("#phases_navigation_state");
    $processNavState.on("keypress", (event) => {
      if (event.which !== 13) {
        return;
      }
      if ($processNavState.is(":checked")) {
        $processNavState.prop("checked", false);
      } else {
        $processNavState.prop("checked", true);
      }
    });

    // IE polyfills
    $("body").applyPolyfills();

    $(".hide-on-load").removeClass("hide-on-load");

    // Event to determine when the application scripts have finished their setup
    $(document).trigger("app-ready");
  });
})(window);
