$(() => {
  ((exports) => {
    const $processesGrid = $("#processes-grid");
    const $loading = $processesGrid.find(".loading");
    const filterLinksSelector = ".order-by__tabs a"

    $loading.hide();

    $processesGrid.on("click", filterLinksSelector, (event) => {
      let $target = $(event.target);
      const $processesGridCards = $processesGrid.find(".card-grid .column");

      // IE1 recognizes the click event on the <strong> element inside the
      // anchor
      if (!$target.is('a')) {
        $target = $target.parents('a').first();
      }

      $(filterLinksSelector).removeClass("is-active");
      $target.addClass("is-active");

      $processesGridCards.hide();
      $loading.show();

      if (exports.history && $target.attr("href")) {
        exports.history.pushState(null, null, $target.attr("href"));
      }
    });
  })(window);

});
