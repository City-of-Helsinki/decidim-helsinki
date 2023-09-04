/**
 * Enables or disables body scrolling.
 *
 * @param {Boolean} enabled Whether the body scroll is enabled (true) or
 *   disabled (false).
 */
const toggleBodyScroll = (enabled) => {
  const html = document.querySelector("html");
  if (enabled) {
    html.classList.remove("is-reveal-open");
  } else {
    html.classList.add("is-reveal-open");
  }
};

/**
 * Tells if the body scroll is currently disabled.
 *
 * @returns {Boolean} Whether body scroll is disabled or not.
 */
const bodyScrollDisabled = () => {
  const html = document.querySelector("html");
  return html.classList.contains("is-reveal-open");
}

/**
 * Toggles the focus guard within the header element when the menu is active.
 *
 * @param {HTMLElement} header The header element.
 * @param {String} mode Layout mode (either "desktop" or "mobile").
 */
const toggleFocusGuard = (header, mode = "mobile") => {
  if (header.getAttribute("data-navbar-active")) {
    if (mode === "desktop") {
      window.focusGuard.disable();
    } else {
      window.focusGuard.trap(header);
    }
  } else if (!bodyScrollDisabled()) {
    window.focusGuard.disable();
  }
};

/**
 * Moves the mobile user menu elements to the correct container based on the
 * current layout mode. This cannot be done with the `.js-append` (i.e.
 * `@zeitiger/appendaround`) because of the difference for the menu structures.
 *
 * @param {String} mode Either "desktop" or "mobile" identifying the current
 *   layout mode. Layouts "large", "xlarge" and "xxlarge" are considered desktop
 *   modes.
 */
const moveUserMenu = (mode) => {
  const desktopMenu = document.getElementById("user-menu");
  const mobileMenu = document.getElementById("user-menu-mobile");
  if (!desktopMenu || !mobileMenu) {
    return;
  }

  let source = desktopMenu;
  let target = mobileMenu;
  if (mode === "desktop") {
    source = mobileMenu;
    target = desktopMenu;
  }

  target.append(...source.childNodes);
};

/**
 * Disables or enables the body scroll when the header menu is open on mobile.
 * If the menu was opened on mobile and then the layout was changed to desktop,
 * this will re-enable body scroll automatically.
 *
 * @param {HTMLElement} header The header element to check the activity state
 *   from.
 * @param {String} mode The layout mode, either "desktop" or "mobile".
 */
const toggleHeaderMenu = (header, mode = "mobile") => {
  if (!header.getAttribute("data-navbar-active")) {
    toggleFocusGuard(header, mode);
    return;
  }

  if (mode === "desktop") {
    toggleBodyScroll(true);
    toggleFocusGuard(header, mode);
  } else {
    toggleBodyScroll(false);
    toggleFocusGuard(header, mode);
  }
};

const handleLayoutChange = (header, currentSize) => {
  const desktopSizes = ["large", "xlarge", "xxlarge"];
  const mode = desktopSizes.includes(currentSize) ? "desktop" : "mobile";

  toggleHeaderMenu(header, mode);
  moveUserMenu(mode);
};

const navbarToggles = (header) => {
  header.querySelectorAll("[data-navbar-toggle]").forEach((toggle) => {
    const target = toggle.getAttribute("data-navbar-toggle");

    toggle.addEventListener("click", (ev) => {
      const current = header.getAttribute("data-navbar-active");

      if (target === current) {
        toggleBodyScroll(true);
        header.removeAttribute("data-navbar-active");
        toggleFocusGuard(header);
      } else {
        toggleBodyScroll(false);
        header.setAttribute("data-navbar-active", target);
        toggleFocusGuard(header);
      }
    });
  });
};

/**
 * Initializes the header functionality.
 */
export default () => {
  const header = document.getElementById("header");
  if (!header) {
    return;
  }

  navbarToggles(header);

  // Foundation requires jQuery
  $(header).on("on.zf.toggler", () => toggleHeaderMenu(header));
  $(header).on("off.zf.toggler", () => toggleHeaderMenu(header));
  $(window).on("changed.zf.mediaquery", (ev, newSize) => {
    handleLayoutChange(header, newSize);
  });

  handleLayoutChange(header, Foundation.MediaQuery.current);
}
