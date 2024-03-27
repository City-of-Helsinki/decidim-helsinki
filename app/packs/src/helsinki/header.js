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

    toggle.setAttribute("aria-expanded", false);
    toggle.addEventListener("click", (ev) => {
      const current = header.getAttribute("data-navbar-active");

      // Set other toggles as not expanded
      header.querySelectorAll("[data-navbar-toggle]").forEach((otherToggle) => {
        if (otherToggle === toggle) {
          return;
        }
        otherToggle.setAttribute("aria-expanded", false);
      });

      if (target === current) {
        toggleBodyScroll(true);
        header.removeAttribute("data-navbar-active");
        toggle.setAttribute("aria-expanded", false);
        toggleFocusGuard(header);
      } else {
        toggleBodyScroll(false);
        header.setAttribute("data-navbar-active", target);
        toggle.setAttribute("aria-expanded", true);
        toggleFocusGuard(header);
      }
    });
  });
};

const navbarSubmenus = (header) => {
  const itemsWithSubmenu = header.querySelectorAll(".menu-link[data-submenu]");
  const toggleSubmenu = (menuItem, state) => {
    const toggle = menuItem.querySelector(":scope > button");
    const submenu = menuItem.querySelector(":scope > .submenu");

    if (state === "open") {
      // Close all other items
      itemsWithSubmenu.forEach((item) => {
        if (item === menuItem) {
          return;
        }
        toggleSubmenu(item, "closed");
      });

      submenu.classList.add("open");
      toggle.setAttribute("aria-expanded", true);
      toggle.setAttribute("aria-label", toggle.getAttribute("data-label-active"));
    } else {
      submenu.classList.remove("open");
      toggle.setAttribute("aria-expanded", false);
      toggle.setAttribute("aria-label", toggle.getAttribute("data-label-inactive"));
    }
  };

  // When clicked outside of the submenu elements, close all open submenus
  document.addEventListener("click", (ev) => {
    if (ev.target.closest(".menu-link[data-submenu]")) {
      return;
    }

    itemsWithSubmenu.forEach((item) => toggleSubmenu(item, "closed"));
  });

  itemsWithSubmenu.forEach((menuItem) => {
    const toggle = menuItem.querySelector(":scope > button");
    const submenu = menuItem.querySelector(":scope > .submenu");

    toggle.setAttribute("data-label-inactive", toggle.getAttribute("aria-label"));

    let mouseInside = false;
    menuItem.addEventListener("mouseenter", () => {
      mouseInside = true;
      toggleSubmenu(menuItem, "open");
    });
    menuItem.addEventListener("mouseleave", () => {
      mouseInside = false;
      if (toggle.getAttribute("data-active") === "true") {
        return;
      }
      toggleSubmenu(menuItem, "closed");
    });
    toggle.addEventListener("mouseenter", () => {
      if (toggle.getAttribute("data-active") === "true") {
        return;
      }

      toggleSubmenu(menuItem, "closed");
    });
    toggle.addEventListener("mouseleave", () => {
      if (mouseInside) {
        toggleSubmenu(menuItem, "open");
      }
    });
    toggle.addEventListener("click", () => {
      if (submenu.classList.contains("open")) {
        toggleSubmenu(menuItem, "closed");
        toggle.removeAttribute("data-active");
      } else {
        toggleSubmenu(menuItem, "open");
        toggle.setAttribute("data-active", true);
      }
    });
  });
}

/**
 * Initializes the header functionality.
 */
export default () => {
  const header = document.getElementById("header");
  if (!header) {
    return;
  }

  navbarToggles(header);
  navbarSubmenus(header);

  // Foundation requires jQuery
  $(header).on("on.zf.toggler", () => toggleHeaderMenu(header));
  $(header).on("off.zf.toggler", () => toggleHeaderMenu(header));
  $(window).on("changed.zf.mediaquery", (ev, newSize) => {
    handleLayoutChange(header, newSize);
  });

  handleLayoutChange(header, Foundation.MediaQuery.current);
}
