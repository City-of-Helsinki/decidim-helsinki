$.fn.toggleCheckbox = function() {
  return $(this).each((_i, element) => {
    $(element).on("click", function() {
      const $target = $(`#${$(element).data("toggle-checkbox")}`);

      if ($target.is(":checked")) {
        $target.prop("checked", false);
      } else {
        $target.prop("checked", true);
      }

      // Initiate the listeners on the checkbox
      $target.trigger("change");
    });
  });
};
