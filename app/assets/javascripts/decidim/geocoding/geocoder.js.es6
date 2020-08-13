((exports) => {
  exports.Decidim = exports.Decidim || {};

  class Geocoder {
    constructor(config) {
      this.config = config;
    }

    suggestions(query, callback) {
      if (!this.config.url || this.config.url.length < 1) {
        return;
      }

      clearTimeout(this.currentSuggestionQuery);

      this.currentSuggestionQuery = setTimeout(() => {
        $.ajax({
          method: "GET",
          url: this.config.url,
          data: { query: query },
          dataType: "json"
        }).done((resp) => {
          if (resp.success) {
            return callback(resp.results.map((item) => {
              return {
                key: item.label,
                value: item.label
              }
            }));
          }
          return null;
        });
      }, 200);
    }
  }

  exports.Decidim.Geocoder = Geocoder;
})(window);
