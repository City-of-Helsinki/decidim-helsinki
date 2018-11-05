(function($, Decidim, window) {

$.fn.fixMapToggle = function() {
  return $(this).on('on.zf.toggler off.zf.toggler', function() {
    var $container = $(this);
    var $map = $('.leaflet-container', $container);

    if ($map.is(':visible')) {
      // Wait for the element to appear
      setTimeout(function() {
        if ($map.length > 0 && Decidim.currentMap) {
          // See:
          // https://leafletjs.com/reference-1.3.4.html#map-invalidatesize
          Decidim.currentMap.invalidateSize(false);

          var markersData = $map.data("markers-data");

          if (markersData.length == 1) {
            // Center to the marker with a sensible default zoom level
            var marker = markersData[0];
            Decidim.currentMap.setView([marker.latitude, marker.longitude], 12);
          } else {
            // Re-center the map as done in `decidim/map.js.es6`
            var bounds = null;
            if (markersData.length > 0) {
              bounds = new window.L.LatLngBounds(markersData.map(
                (markerData) => [markerData.latitude, markerData.longitude]
              ));
            } else {
              // In case no markers are available, center Helsiki city bounds
              bounds = new window.L.LatLngBounds([
                [60.142327,24.854767],
                [60.142327,24.854081],
                [60.214377,25.147842],
                [60.214377,25.147842]
              ]);
            }
            Decidim.currentMap.fitBounds(bounds, { padding: [100, 100] });
          }
        }

        // Scroll to the element
        $target.scrollTo();
      }, 100);
    }
  });
};

})(jQuery, Decidim, window);
