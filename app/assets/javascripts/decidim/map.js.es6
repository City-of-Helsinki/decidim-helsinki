// = require decidim/map/factory
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line

  exports.Decidim = exports.Decidim || {};

  $(() => {
    // Load the map controller factory method in the document.ready handler to
    // allow overriding it by any script that is loaded before the document is
    // ready.
    const createMapController = exports.Decidim.createMapController;

    $("[data-decidim-map]").each((_i, el) => {
      const $map = $(el);
      const mapId = $map.attr("id");

      const mapConfig = $map.data("decidim-map");
      const ctrl = createMapController(mapId, mapConfig);
      const map = ctrl.load();

      $map.data("map", map);
      $map.data("map-controller", ctrl);

      $map.trigger("configure.decidim", [map, mapConfig]);

      ctrl.start();

      // Indicates the map is loaded with the map objects initialized and ready
      // to be used.
      $map.trigger("ready.decidim", [map, mapConfig]);
    });
  });
})(window);
