$.fn.fixMapToggle = function() {
  return $(this).on("on.zf.toggler off.zf.toggler", (ev) => {
    const Leaflet = window.L;
    const $container = $(ev.target);
    const $map = $("[data-decidim-map]:first", $container);

    if ($map.length > 0 && $map.is(":visible")) {
      // Wait for the element to appear
      setTimeout(function() {
        const map = $map.data("map");
        if (!map) {
          return;
        }

        // See:
        // https://leafletjs.com/reference-1.3.4.html#map-invalidatesize
        map.invalidateSize(false);

        const mapConfig = $map.data("decidim-map");
        const markersData = mapConfig.markers;

        if (markersData.length === 1) {
          // Center to the marker with a sensible default zoom level
          const marker = markersData[0];
          map.setView([marker.latitude, marker.longitude], 12);
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
          map.fitBounds(bounds, { padding: [100, 100] });
        }
      }, 100);
    }
  });
};
