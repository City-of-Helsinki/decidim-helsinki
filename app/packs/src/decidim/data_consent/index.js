/**
 * Customized version of the data/cookie consent management as Helsinki uses
 * an external provider for this (CookieHub).
 */

/**
 * Manages the consent
 */
class ConsentManager {
  allAccepted() {
    if (!window.cookiehub) {
      // When CookieHub is disabled (like in development), we consider all
      // categories accepted.
      return true;
    }
    if (!window.cookiehub.hasAnswered()) {
      return false;
    }

    return ["preferences", "analytics", "marketing"].every((category) => {
      const categoryResponse = window.cookiehub.hasConsented(category);
      return categoryResponse === undefined || categoryResponse === true;
    })
  }

  openSettings() {
    if (!window.cookiehub) {
      return;
    }

    window.cookiehub.openSettings();
  }
}

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

    let cloned = warningElement.cloneNode(true);
    cloned.classList.remove("hide");
    original.appendChild(cloned);

    // Listen to the click on the settings button
    cloned.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", (ev) => {
        ev.preventDefault();
        manager.openSettings();
      });
    })
  });
};

document.addEventListener("DOMContentLoaded", () => {
  const manager = new ConsentManager();

  triggerIframes(manager);
  triggerWarnings(manager);

  document.documentElement.addEventListener("cookiehub:statusChange", () => {
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
