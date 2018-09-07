(function($) {

$.fn.fixNavbar = function() {
    var fixPos = $(this).data('navbar-fix-position');
    if (!fixPos) {
        $('body').removeClass('nav-fixed');
        var fixPos = $(this).offset().top + $(this).height();
        $(this).data('navbar-fix-position', fixPos);
    }

    if ($(window).scrollTop() > fixPos) {
        $('body').addClass('nav-fixed');
        $('.navbar-primary-fixed-placeholder').height($(this).height());
    } else {
        $('body').removeClass('nav-fixed');
        $('.navbar-primary-fixed-placeholder').height(0);
    }

    return $(this);
};

})(jQuery);
