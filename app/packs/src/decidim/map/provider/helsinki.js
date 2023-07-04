import "leaflet";

$(() => {
  const lang = $("html").attr("lang");
  let langSuffix = "";
  if (lang === "sv") {
    langSuffix = `@${lang}`;
  }

  $("[data-decidim-map]").on("configure.decidim", (_ev, map, mapConfig) => {
    const tilesConfig = mapConfig.tileLayer;
    L.tileLayer(tilesConfig.url, { ...tilesConfig.options, lang: langSuffix }).addTo(map);
  });
});
