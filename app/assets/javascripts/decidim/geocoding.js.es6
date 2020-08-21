// = require tribute

((exports) => {
  const $ = exports.$; // eslint-disable-line
  const Tribute = exports.Tribute;

  $(() => {
    $("[data-decidim-geocoding]").each((_i, el) => {
      const $input = $(el);

      const tribute = new Tribute(
        {
          autocompleteMode: true,
          autocompleteSeparator: " + ",
          allowSpaces: true,
          noMatchTemplate: null,
          values: (text, cb) => {
            $input.trigger("geocoder-suggest.decidim", [text, cb]);
          }
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

      $input.data("geocoder-tribute", tribute);
    });
  });
})(window);
