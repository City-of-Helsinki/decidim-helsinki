// = require decidim/geocoding
// = require_self

((exports) => {
  exports.Decidim = exports.Decidim || {};

  const Geocoder = exports.Decidim.Geocoder;

  class HelsinkiGeocoder extends Geocoder {
    suggestions(query, callback) {
      clearTimeout(this.currentSuggestionQuery);

      if (query.length < 2) {
        return;
      }

      this.currentSuggestionQuery = setTimeout(() => {
        const language = $("html").attr("lang");

        const suggestions = $.ajax({
          method: "GET",
          url: "https://api.hel.fi/servicemap/v2/suggestion/",
          data: { q: query, language: language === "sv" ? language : "fi" }, // eslint-disable-line
          dataType: "json"
        });
        const geocoding = $.ajax({
          method: "GET",
          url: this.config.url,
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
    }
  }

  exports.Decidim.Geocoder = HelsinkiGeocoder;
})(window);
