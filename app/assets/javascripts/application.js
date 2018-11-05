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
//
//= require jquery
//= require rails-ujs
//= require activestorage
//= require cable
//= require_self
//= require decidim
//= require ie-polyfills
//= require app/toggle-checkbox
//= require app/fix-map-toggle

(function ($) {
  $(document).on('ready', function () {
    $('#proposals-map-container').fixMapToggle();
    $('[data-toggle-checkbox]').toggleCheckbox();

    // IE polyfills
    $('body').applyPolyfills();

    // Event to determine when the application scripts have finished their setup
    $(document).trigger('app-ready');
  })
})($);
