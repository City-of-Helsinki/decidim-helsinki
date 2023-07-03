// = require decidim/ideas/map/factory

((exports) => {
  const $ = exports.$; // eslint-disable-line
  const L = window.L;  // eslint-disable-line

  let domReady = false;
  let mapReady = false;
  let districtsInit = () => {
    // The districts init cannot run if the DOM is not ready yet because
    // otherwise leaflet would cause an error.
    if (!domReady || !mapReady) {
      return;
    }

    $("[data-decidim-map]").each((_i, el) => {
      const $map = $(el);
      const ctrl = $map.data("map-controller");
      const mapConfig = ctrl.getConfig();

      // We don't want to add the districts to the map on the idea form page
      if (mapConfig.type) {
        return;
      }

      // Get the district boundaries to the map
      $.get({
        url: "https://api.hel.fi/servicemap/v2/administrative_division/?page=1&page_size=20&type=major_district&geometry=true",
        success: (data) => {
          if (!data || !data.results) {
            return;
          }

          // https://hds.hel.fi/design-tokens/colour
          const styles = [
            { color: "#000098" },
            { color: "#0072c6" },
            { color: "#c2a251" },
            { color: "#00d7a7" },
            { color: "#fd4f00" },
            { color: "#fea780" },
            { color: "#de7ba6" },
            { color: "#8d0d2d" }
          ];

          $.each(data.results, (di, district) => {
            const name = district.name;
            let lang = "fi";
            if ($("html").attr("lang") === "sv") {
              lang = "sv";
            }

            const mapFeature = {
              type: "Feature",
              properties: {
                name: name[lang]
              },
              geometry: district.boundary
            };
            const layer = L.geoJSON(mapFeature, styles[di]);
            layer.addTo(ctrl.getMap());

            layer.on("mouseover", () => {
              if (layer.isPopupOpen()) {
                return;
              }
              layer.bindTooltip(name[lang], {
                className: "map-district-label",
                offset: [0, 0],
                direction: "top"
              }).openTooltip();
            });
          });
        }
      });
    });
  };

  $("[data-decidim-map]").on("configure.decidim", (ev) => {
    const $map = $(ev.target);
    const ctrl = $map.data("map-controller");
    const map = ctrl.getMap();

    map.on("load", () => {
      mapReady = true;
      districtsInit();
    });
  });

  $("[data-decidim-map]").on("ready.decidim", (ev, _map, mapConfig) => {
    const $map = $(ev.target);
    const ctrl = $map.data("map-controller");

    // If it's an idea form map, bind the connected input with the map events
    // and send the coordinates from the input to the map when received.
    if (mapConfig.type === "idea-form") {
      const $connectedInput = $($map.data("connected-input"));

      // The map triggers a "coordinates" event when the marker is placed on
      // the map. This sends the coordinates to the connected input.
      ctrl.setEventHandler("coordinates", (latlng) => {
        $connectedInput.trigger("coordinates.decidim.ideas", [latlng]);
      });

      // The map triggers a "specify" event when an existing marker is moved on
      // the map. This sends the coordinates to the connected input for update.
      ctrl.setEventHandler("specify", (latlng) => {
        $connectedInput.trigger("specify.decidim.ideas", [latlng]);
      });

      // The input can trigger a "coordinates" event on the map element meaning
      // that the user searched for an address which returned a map point which
      // should be placed on the map.
      $map.on("coordinates.decidim.ideas", (_ev, coordinates) => {
        if (coordinates === null) {
          // When the coordinates is null, the marker should be removed if it
          // exists.
          ctrl.removeMarker();
          return;
        }

        ctrl.receiveCoordinates(coordinates.lat, coordinates.lng);
      });
    }
  });

  $(document).ready(() => {
    domReady = true;
    districtsInit();
  });
})(window);
