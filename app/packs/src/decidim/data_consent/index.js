/**
 * Customized version of the data/cookie consent management as Helsinki uses its
 * own cookie management solution.
 */
import initDataConsent from "src/helsinki/data_consent";

const CATEGORIES = ["preferences", "statistics", "marketing"];

/**
 * Manages the consent
 */
class ConsentManager {
  constructor(hds) {
    this.hds = hds;
  }

  allAccepted() {
    return this.isAccepted(CATEGORIES);
  }

  isAccepted(categories) {
    let cats = categories;
    if (typeof categories === "string") {
      cats = [categories];
    }
    return this.hds.getConsentStatus(cats);
  }

  openSettings() {
    this.hds.openBanner();
  }
}

/**
 * Parses details about the iframe to display within the disabled iframe
 * notification. The parsed details are the `src` of the iframe to allow linking
 * directly to the content and `domain` to display from which domain the content
 * is originating from.
 *
 * @param {Node} disabledNode The disabled iframe node containing the commented
 *   iframe.
 * @returns {Object} An object containing `src` and `domain` for the provided
 *   iframe or an empty Object in case these details are not found.
 */
const getDisabledIframeDetails = (disabledNode) => {
  const commentNode = disabledNode.childNodes.values().find((node) => node.nodeType === Node.COMMENT_NODE);
  if (!commentNode) {
    return {};
  }

  const parser = new DOMParser();
  const dom = parser.parseFromString(commentNode.textContent, "text/html");
  const iframe = dom.querySelector("iframe");
  if (!iframe) {
    return {};
  }

  const iframeSrc = iframe.getAttribute("src");
  if (!iframeSrc) {
    return {};
  }

  const match = iframeSrc.match(/^(https?:)?\/\/([^\/?]+)/);
  if (!match) {
    return { src: iframeSrc };
  }

  return { src: iframeSrc, domain: match[2] };
}

/**
 * Triggers javascript visibility based on the user's cookie settings.
 *
 * @param {ConsentManager} manager
 */
const triggerJavascripts = (manager) => {
  for (const category of CATEGORIES) {
    const accepted = manager.isAccepted(category);

    for (const el of document.querySelectorAll(`script[data-consent="${category}"]`)) {
      let expectedType = "text/plain";
      if (accepted) {
        expectedType = null;
      }
      if (el.getAttribute("type") === expectedType) {
        continue;
      }

      const newEl = document.createElement("script");
      newEl.setAttribute("data-consent", category);
      newEl.innerHTML = el.innerHTML;
      if (!accepted) {
        newEl.setAttribute("type", "text/plain");
      }
      el.replaceWith(newEl);
    }
  }
};

/**
 * Triggers iframe visibility based on the user's cookie settings. If the user
 * has allowed all categories, the iframes are visible. Otherwise they are
 * hidden.
 *
 * @param {ConsentManager} manager
 */
const triggerIframes = (manager) => {
  if (manager.allAccepted()) {
    document.querySelectorAll(".disabled-iframe").forEach((original) => {
      if (original.childNodes && original.childNodes.length) {
        const content = Array.from(original.childNodes).find((childNode) => {
          return childNode.nodeType === Node.COMMENT_NODE;
        });
        if (!content) {
          return;
        }
        const newElement = document.createElement("div");
        newElement.innerHTML = content.nodeValue;
        original.parentNode.replaceChild(newElement.firstElementChild, original);
      }
    });
  } else {
    document.querySelectorAll(".iframe-embed").forEach((original) => {
      const newElement = document.createElement("div");
      newElement.className = "disabled-iframe";
      newElement.appendChild(document.createComment(`${original.outerHTML}`));
      original.parentNode.replaceChild(newElement, original);
    });
  }
};

/**
 * Triggers the warning elements inside the disabled iframes.
 *
 * @param {ConsentManager} manager
 */
const triggerWarnings = (manager) => {
  const warningElement = document.querySelector(".dataconsent-warning");

  document.querySelectorAll(".disabled-iframe").forEach((original) => {
    if (original.querySelector(".dataconsent-warning")) {
      return;
    }

    const details = getDisabledIframeDetails(original);

    let cloned = warningElement.cloneNode(true);
    cloned.classList.remove("hide");
    original.appendChild(cloned);

    cloned.querySelector("[data-content-source-text]").innerText = details.domain;
    cloned.querySelector("[data-content-source-link]").setAttribute("href", details.src || "#");

    // Listen to the click on the settings button
    cloned.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", (ev) => {
        ev.preventDefault();
        manager.openSettings();
      });
    })
  });
};

document.addEventListener("DOMContentLoaded", async () => {
  const hdsManager = await initDataConsent();
  const manager = new ConsentManager(hdsManager);

  triggerJavascripts(manager);
  triggerIframes(manager);
  triggerWarnings(manager);

  window.addEventListener("hds-cookie-consent-changed", () => {
    triggerJavascripts(manager);
    triggerIframes(manager);
    triggerWarnings(manager);
  });

  document.querySelectorAll("[data-cookie-settings]").forEach((trigger) => {
    trigger.addEventListener("click", (ev) => {
      ev.preventDefault();
      manager.openSettings();
    })
  })
});
