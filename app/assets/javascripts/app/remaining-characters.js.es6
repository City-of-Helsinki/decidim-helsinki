((exports) => {
  // eslint-disable-next-line id-length
  const $ = exports.$;

  const COUNT_KEY = "%count%";

  $.fn.remainingCharacters = function() {
    return $(this).each((_i, element) => {
      const $input = $(element);
      const $target = $($input.data("remaining-characters"));
      const maxCharacters = parseInt($(element).attr("maxlength"), 10);

      if ($target.length > 0 && maxCharacters > 0) {
        const messagesJson = $input.data("remaining-characters-messages");
        const messages = $.extend({
          one: `${COUNT_KEY} character left`,
          many: `${COUNT_KEY} characters left`
        }, messagesJson);

        const updateStatus = () => {
          const numCharacters = $input.val().length;
          const remaining = maxCharacters - numCharacters;
          let message = messages.many;
          if (remaining === 1) {
            message = messages.one;
          }

          $target.text(message.replace(COUNT_KEY, remaining));
        };

        $input.on("keyup", function() {
          updateStatus();
        });
        updateStatus();
      }
    });
  };

})(window);
