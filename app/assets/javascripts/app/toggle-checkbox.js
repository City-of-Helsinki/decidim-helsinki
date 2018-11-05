(function($) {

$.fn.toggleCheckbox = function() {
  return $(this).each(function() {
    $(this).on('click', function() {
      var $target = $('#' + $(this).data('toggle-checkbox'));

      if ($target.is(':checked')) {
        $target.prop('checked', false);
      } else {
        $target.prop('checked', true);
      }

      // Initiate the listeners on the checkbox
      $target.trigger('change');
    });
  });
};

})(jQuery);
