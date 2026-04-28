const i18n = {
  fi: {
    closeLabel: "Sulje"
  },
  sv: {
    closeLabel: "Stäng"
  },
  en: {
    closeLabel: "Close"
  }
};

export default () => {
  let lang = document.documentElement.getAttribute("lang");
  if (!i18n[lang]) {
    lang = "en";
  }

  const dict = i18n[lang];

  return `
    <div class="reveal" id="mapMarkerPopup" data-reveal role="dialog" aria-modal="true" aria-labelledby="mapMarkerPopup-label">
      <div class="reveal__header">
        <h2 id="mapMarkerPopup-label" class="reveal__title"></h2>
        <button class="close-button" data-close aria-label="${dict.closeLabel}" type="button">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="reveal__content"></div>
      <div class="buttons buttons-row">
        <a href="#" class="button" data-action></a>
        <button type="button" class="button hollow" data-close>${dict.closeLabel}</button>
      </div>
    </div>
  `;
};

