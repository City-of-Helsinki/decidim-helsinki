// = require tribute
// = require decidim/geocoding/geocoder

((exports) => {
  const $ = exports.$; // eslint-disable-line
  const Tribute = exports.Tribute;

  exports.Decidim = exports.Decidim || {};

  $(() => {
    // Load the final geocoder after document.ready in order to allow the
    // individual providers to override the default Geocoder.
    const Geocoder = exports.Decidim.Geocoder;

    $("[data-decidim-geocoding]").each((_i, el) => {
      const $input = $(el);
      const config = $input.data("decidim-geocoding");
      const geocoder = new Geocoder(config);

      const tribute = new Tribute(
        {
          autocompleteMode: true,
          autocompleteSeparator: " + ",
          allowSpaces: true,
          noMatchTemplate: null,
          values: (text, cb) => geocoder.suggestions(text, (results) => {
            $input.trigger("geocoder-suggest.decidim", [results]);

            return cb(results);
          })
        }
      );

      // Port https://github.com/zurb/tribute/pull/406
      // This changes the autocomplete separator from space to " + " so that
      // we can do searches such as "streetname 4".
      tribute.range.getLastWordInText = (text) => {
        const final = text.replace(/\u00A0/g, " ");
        const wordsArray = final.split(/ \+ /);
        const worldsCount = wordsArray.length - 1;

        return wordsArray[worldsCount].trim();
      };

      tribute.attach($input.get(0));

      $input.data("geocoder", geocoder);
      $input.data("geocoder-tribute", tribute);
    });
  });
})(window);
