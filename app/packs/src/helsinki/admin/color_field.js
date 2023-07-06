((exports) => {
  const $ = exports.$; // eslint-disable-line

  let hasColor = $("[name='category[has_color]']");
  let colorField = $("[name='category[color]']");

  let hasColorChecked = () => {
    return hasColor.is(":checked");
  };

  let colorFieldEnabled = () => {
    colorField.removeAttr("disabled");
    colorField.parent().show();
  };

  let colorFieldDisabled = () => {
    colorField.attr("disabled", "false");
    colorField.parent().hide();
  };

  // default state
  if (hasColorChecked()) {
    colorFieldEnabled();
  } else {
    colorFieldDisabled();
  }

  hasColor.on("change", () => {
    if (hasColorChecked()) {
      colorFieldEnabled();
    } else {
      colorFieldDisabled();
    }
  });
})(window);
