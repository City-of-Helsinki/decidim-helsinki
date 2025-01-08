import { CookieConsentCore } from "hds-js";
import cookieSettings from "src/helsinki/cookie_consent/settings";

export default async () => {
  await CookieConsentCore.create(cookieSettings, {
    language: "fi",
    theme: "bus",
    targetSelector: "body",
    spacerParentSelector: "body",
    pageContentSelector: "body",
    submitEvent: false,
    settingsPageSelector: null,
    focusTargetSelector: null,
    disableAutoRender: false,
  });
};
