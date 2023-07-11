import "src/decidim/geocoding";

$(() => {
  $("[data-decidim-geocoding]").each((_i, el) => {
    const $input = $(el);
    const config = $input.data("decidim-geocoding");
    let currentSuggestionQuery = null;

    if (!config.url || config.url.length < 1) {
      return;
    }

    $input.on("geocoder-suggest.decidim", (_ev, query, callback) => {
      clearTimeout(currentSuggestionQuery);
      if (query.length < 2) {
        return;
      }

      currentSuggestionQuery = setTimeout(() => {
        const language = $("html").attr("lang");

        const suggestions = $.ajax({
          method: "GET",
          url: "https://api.hel.fi/servicemap/v2/suggestion/",
          data: { q: query, language: language === "sv" ? language : "fi" }, // eslint-disable-line
          dataType: "json"
        });
        const geocoding = $.ajax({
          method: "GET",
          url: config.url,
          data: { query: query },
          dataType: "json"
        });

        Promise.all([suggestions, geocoding]).then((values) => {
          const results = [];

          const suggestionResult = values[0];
          if (suggestionResult && suggestionResult.suggestions) {
            results.push(...suggestionResult.suggestions.map((data) => {
              return {
                key: data.suggestion,
                value: data.suggestion
              };
            }));
          }

          const geocodingResult = values[1];
          if (geocodingResult.success) {
            results.push(...geocodingResult.results.map((item) => {
              return {
                key: item.label,
                value: item.label,
                coordinates: item.coordinates
              };
            }));
          }

          callback(results)
        });
      }, 300);
    });
  })
});
