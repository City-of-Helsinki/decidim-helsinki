(function($) {

var COUNT_KEY = '%count%';

$.fn.remainingCharacters = function() {
  return $(this).each(function() {
    var $input = $(this);
    var $target = $($input.data('remaining-characters'));
    var maxCharacters = parseInt($(this).attr('maxlength'));

    if ($target.length > 0 && maxCharacters > 0) {
      var messagesJson = $input.data('remaining-characters-messages');
      var messages = $.extend({
        one: COUNT_KEY + ' character left',
        many: COUNT_KEY + ' characters left',
      }, messagesJson);

      var updateStatus = function() {
        var numCharacters = $input.val().length;
        var remaining = maxCharacters - numCharacters;
        var message = remaining === 1 ? messages['one'] : messages['many'];

        $target.text(message.replace(COUNT_KEY, remaining));
      };

      $input.on('keyup', function() {
        updateStatus();
      });
      updateStatus();
    }
  });
};

})(jQuery);
