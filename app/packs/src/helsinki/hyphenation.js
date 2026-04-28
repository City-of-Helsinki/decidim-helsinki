// This file is loaded separately at the `hyphenation_xx.js` entrypoints where
// the `xx` suffix represents the language code. Do not import this file
// elsewhere. This is done so to only load the required dictionary for the
// current language.

// Note that this works up until Hyphenopoly version 5.2.1. Newer versions fail
// to build with webpack due to the following change:
// https://github.com/mnater/Hyphenopoly/commit/b732a4f8c51eef1b8d9c26fa41d434aafe3f95ff
//
// The relevant change is the addition of the `new URL(...)` parameters which
// cannot be resolved by webpack.

import hyphenopoly from "hyphenopoly";

const hyphenate = (container, baseConfig) => {
  container.querySelectorAll("[data-hyphenate]").forEach(async (el) => {
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
}

export default (base64Dict, locale, exceptions = {}) => {
  fetch(base64Dict).then((res) => res.arrayBuffer()).then((buffer) => {
    const dictBuffer = new Uint8Array(buffer);
    const baseConfig = {
      require: [locale],
      loader: async (_file) => dictBuffer,
      exceptions
    }

    hyphenate(document, baseConfig);

    document.addEventListener("section:update", (ev) => {
      hyphenate(ev.target, baseConfig);
    });
  });
};
