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

(function ($) {
  $(document).on('ready', function () {
    // $('.match-height').matchHeight()
    // $('.navbar-primary').fixNavbar();

    // setTimeout(function () {
    //     // Sometimes it takes a while to render after the document is ready
    //   $('.match-height').matchHeight()
    // }, 500)

    $(window).resize(function () {
     // $('.match-height').matchHeight()
     // $('.navbar-primary').removeData('navbar-fix-position')
   });
    $(window).on('scroll', function () {
      // $('.navbar-primary').fixNavbar()
    });

    // IE polyfills
    $('body').applyPolyfills();
  })
})($);
