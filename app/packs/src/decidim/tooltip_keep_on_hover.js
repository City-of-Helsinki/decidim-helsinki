/* eslint-disable no-invalid-this */

$(() => {
  // Fixes an issue with the data-click-open tooltips that the clicks to the
  // toggle element won't close the tooltip.
  $("[data-tooltip][data-click-open='true']").each((_i, el) => {
    const $toggle = $(el);
    const $tooltip = $(`#${$toggle.data("toggle")}`);
    if ($tooltip.length < 1) {
      return;
    }

    let tooltipOpen = false;
    let showTo = null;
    $toggle.on("show.zf.tooltip", () => {
      clearTimeout(showTo);
      showTo = setTimeout(() => tooltipOpen = true, 200);
    });
    $toggle.on("hide.zf.tooltip", () => tooltipOpen = false);

    $toggle.on("click", (ev) => {
      if (tooltipOpen) {
        $toggle.foundation("hide");
      }
    });
  });
});
