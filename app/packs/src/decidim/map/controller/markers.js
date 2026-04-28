import "src/decidim/vendor/jquery-tmpl";
import MapController from "src/decidim/map/controller";
import markerPopupTemplate from "src/decidim/map/popup";
import "leaflet.markercluster";

/**
 * Overridden because of the following reasons:
 *
 * 1. To separate the map popups to an element outside of the map itself to make
 *    them work better on mobile.
 * 2. To disable the map popups for views that do not define the template, i.e.
 *    the single resource view.
 */
export default class MapMarkersController extends MapController {
  start() {
    this.markerClusters = null;

    if (Array.isArray(this.config.markers) && this.config.markers.length > 0) {
      this.addMarkers(this.config.markers);
    } else {
      this.map.fitWorld();
    }
  }

  addMarkers(markersData) {
    if (this.markerClusters === null) {
      this.markerClusters = new L.MarkerClusterGroup();
      this.map.addLayer(this.markerClusters);
    }

    const hasPopupTemplate = !!document.getElementById(this.config.popupTemplateId);

    // Pre-compiles the popup element
    $("body").append(markerPopupTemplate());
    const $markerPopup = $(mapMarkerPopup);
    $markerPopup.foundation();

    const $markerActionButton = $(".button[data-action]", $markerPopup);
    $markerActionButton.addClass("hide");

    if (hasPopupTemplate) {
      // Pre-compiles the template
      $.template(
        this.config.popupTemplateId,
        $(`#${this.config.popupTemplateId}`).html()
      );
    }

    const bounds = new L.LatLngBounds(
      markersData.map(
        (markerData) => [markerData.latitude, markerData.longitude]
      )
    );

    markersData.forEach((markerData) => {
      let marker = new L.Marker([markerData.latitude, markerData.longitude], {
        icon: this.createIcon(),
        keyboard: true,
        title: markerData.title
      });

      if (hasPopupTemplate) {
        let node = document.createElement("div");
        $.tmpl(this.config.popupTemplateId, markerData).appendTo(node);
        $("h2, h3, h4, h5, h6", node).remove();

        const $markerButton = $(".map-info__button .button", node);
        const buttonLabel = $markerButton.text()?.trim();
        $markerButton.remove();

        marker.on("click", () => {
          $(".reveal__title", $markerPopup).text(markerData.title);
          $(".reveal__content", $markerPopup).empty();
          $(".reveal__content", $markerPopup).append(node);

          if (markerData.link && buttonLabel && buttonLabel.length > 0) {
            $markerActionButton.text(buttonLabel);
            $markerActionButton.attr("href", markerData.link);
            $markerActionButton.removeClass("hide");
          } else {
            $markerActionButton.addClass("hide");
          }

          $markerPopup.foundation("open");
        });
      }

      this.markerClusters.addLayer(marker);
    });

    // Make sure there is enough space in the map for the padding to be
    // applied. Otherwise the map will automatically zoom out (test it on
    // mobile). Make sure there is at least the same amount of width and
    // height available on both sides + the padding (i.e. 4x padding in
    // total).
    const size = this.map.getSize();
    if (size.y >= 400 && size.x >= 400) {
      this.map.fitBounds(bounds, { padding: [100, 100] });
    } else if (size.y >= 120 && size.x >= 120) {
      this.map.fitBounds(bounds, { padding: [30, 30] });
    } else {
      this.map.fitBounds(bounds);
    }

    // Make sure that the map is not zoomed too close if it has only a single
    // marker or few markers nearby each other.
    if (this.map.getZoom() > 15) {
      this.map.setZoom(15);
    }
  }

  clearMarkers() {
    this.map.removeLayer(this.markerClusters);
    this.markerClusters = new L.MarkerClusterGroup();
    this.map.addLayer(this.markerClusters);
  }
}
