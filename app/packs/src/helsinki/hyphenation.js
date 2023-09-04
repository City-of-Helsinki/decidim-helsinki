// This file is loaded separately at the `hyphenation_xx.js` entrypoints where
// the `xx` suffix represents the language code. Do not import this file
// elsewhere. This is done so to only load the required dictionary for the
// current language.

import hyphenopoly from "hyphenopoly";

export default (base64Dict, locale) => {
  fetch(base64Dict).then((res) => res.arrayBuffer()).then((buffer) => {
    const dictBuffer = new Uint8Array(buffer);
    const baseConfig = {
      require: [locale],
      loader: async (_file) => dictBuffer
    }

    document.querySelectorAll("[data-hyphenate]").forEach(async (el) => {
      const config = baseConfig;
      const style = window.getComputedStyle(el);
      const hyphenChars = style["hyphenate-limit-chars"];
      if (hyphenChars) {
        const [min, leftMin, rightMin] = hyphenChars.split(" ");
        config.minWordLength = min || 12;
        config.leftmin = leftMin || 8;
        config.rightmin = rightMin || 4;
      }

      const hyphenator = await hyphenopoly.config(config);

      el.innerText = hyphenator(el.innerText);
    });
  })
}
