import "leaflet";

$(() => {
  const lang = $("html").attr("lang");
  let mapLang = "fi";
  if (lang === "sv") {
    mapLang = lang;
  }

  $("[data-decidim-map]").on("configure.decidim", (_ev, map, mapConfig) => {
    const tilesConfig = mapConfig.tileLayer;
    L.tileLayer(tilesConfig.url, { ...tilesConfig.options, lang: mapLang }).addTo(map);
  });
});
