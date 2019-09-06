((exports) => {
  // eslint-disable-next-line id-length
  const $ = exports.$;
  const Decidim = exports.Decidim;
  const Leaflet = exports.L;

  $.fn.fixMapToggle = function() {
    return $(this).on("on.zf.toggler off.zf.toggler", (ev) => {
      const $container = $(ev.target);
      const $map = $(".leaflet-container", $container);

      if ($map.is(":visible")) {
        // Wait for the element to appear
        setTimeout(function() {
          if ($map.length > 0 && Decidim.currentMap) {
            // See:
            // https://leafletjs.com/reference-1.3.4.html#map-invalidatesize
            Decidim.currentMap.invalidateSize(false);

            const markersData = $map.data("markers-data");

            if (markersData.length === 1) {
              // Center to the marker with a sensible default zoom level
              const marker = markersData[0];
              Decidim.currentMap.setView([marker.latitude, marker.longitude], 12);
            } else {
              // Re-center the map as done in `decidim/map.js.es6`
              let bounds = null;
              if (markersData.length > 0) {
                bounds = new Leaflet.LatLngBounds(markersData.map(function(markerData) {
                  return [markerData.latitude, markerData.longitude];
                }));
              } else {
                // In case no markers are available, center Helsiki city bounds
                bounds = new Leaflet.LatLngBounds([
                  [60.142327, 24.854767],
                  [60.142327, 24.854081],
                  [60.214377, 25.147842],
                  [60.214377, 25.147842]
                ]);
              }
              Decidim.currentMap.fitBounds(bounds, { padding: [100, 100] });
            }
          }
        }, 100);
      }
    });
  };
})(window);
