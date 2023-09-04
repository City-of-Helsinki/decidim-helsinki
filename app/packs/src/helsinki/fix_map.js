/**
 * Borrowed from jQuery.
 *
 * @param {HTMLElement} elem The element to check the visibility for.
 * @returns {Boolean} Indicating if the element is visible or not.
 */
const isVisible = (elem) => {
  return !!(elem.offsetWidth || elem.offsetHeight || elem.getClientRects().length);
}

export default (container) => {
  const Leaflet = window.L;
  const mapEl = container.querySelector("[data-decidim-map]");
  if (!mapEl || !isVisible(mapEl) || mapEl.dataset.mapFixed) {
    return;
  }

  const map = $(mapEl).data("map");
  if (!map) {
    return;
  }

  mapEl.dataset.mapFixed = true;

  setTimeout(() => {
    // See:
    // https://leafletjs.com/reference-1.3.4.html#map-invalidatesize
    map.invalidateSize(false);

    const mapConfig = JSON.parse(mapEl.getAttribute("data-decidim-map"));
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
};
