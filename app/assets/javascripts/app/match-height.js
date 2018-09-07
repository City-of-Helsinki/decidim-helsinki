(function($) {

$.fn.matchHeight = function() {
    var maxHeights = {};

    $(this).css('height', '');

    $(this).each(function() {
        var topOffset = Math.round($(this).offset().top);
        if (maxHeights[topOffset] === undefined) {
            maxHeights[topOffset] = 0;
        }

        $(this).data('top-offset', topOffset);

        var currentHeight = $(this).height();
        if (maxHeights[topOffset] < currentHeight) {
            maxHeights[topOffset] = currentHeight;
        }
    });

    return $(this).each(function() {
        var topOffset = $(this).data('top-offset');
        var height = maxHeights[topOffset];

        if ($(this).height() < height) {
            $(this).height(height);
        }
    });
};

})(jQuery);
