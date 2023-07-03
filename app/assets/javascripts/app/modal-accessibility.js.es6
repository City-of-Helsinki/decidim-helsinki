((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  const focusGuardClass = "focusguard";
  const focusableNodes = ["A", "IFRAME", "OBJECT", "EMBED"];
  const focusableDisableableNodes = ["BUTTON", "INPUT", "TEXTAREA", "SELECT"];

  const isFocusGuard = (element) => {
    return element.classList.contains(focusGuardClass);
  }

  const isFocusable = (element) => {
    if (focusableNodes.indexOf(element.nodeName) > -1) {
      return true;
    }
    if (focusableDisableableNodes.indexOf(element.nodeName) > -1 || element.getAttribute("contenteditable")) {
      if (element.getAttribute("disabled")) {
        return false;
      }
      return true;
    }

    const tabindex = parseInt(element.getAttribute("tabindex"));
    if (!isNaN(tabindex) && tabindex >= 0) {
      return true;
    }

    return false;
  }

  const createFocusGuard = (position) => {
    return $(`<div class="${focusGuardClass}" data-position="${position}" tabindex="0" aria-hidden="true"></div>`);
  };

  const handleContainerFocus = ($container, $guard) => {
    const $reveal = $(".reveal:visible:last", $container);
    if ($reveal.length > 0) {
      handleContainerFocus($reveal, $guard);
      return;
    }

    const $nodes = $("*:visible", $container);
    let $target = null;

    if ($guard.data("position") === "start") {
      // Focus at the start guard, so focus the first focusable element after that
      for (let i = 0; i < $nodes.length; ++i) {
        if (!isFocusGuard($nodes[i]) && isFocusable($nodes[i])) {
          $target = $($nodes[i]);
          break;
        }
      }
    } else {
      // Focus at the end guard, so focus the first focusable element after that
      for (let i = $nodes.length - 1; i >= 0; --i) {
        if (!isFocusGuard($nodes[i]) && isFocusable($nodes[i])) {
          $target = $($nodes[i]);
          break;
        }
      }
    }

    if ($target) {
      $target.focus();
    } else {
      // If no focusable element was found, blur the guard focus
      $guard.blur();
    }
  };

  // This is called every time the modal is opened
  $.fn.modalAccessibility = function() {
    return $(this).each((_i, element) => {
      const $container = $("body");
      const $modal = $(element);
      const $title = $(".reveal__title", $modal);

      if ($title.length > 0) {
        // Focus on the title to make the screen reader to start reading the
        // content within the modal.
        $title.attr("tabindex", $title.attr("tabindex") || -1);
        $title.focus();
      }

      // Once the final modal closes, remove the focus guards from the container
      $modal.off("closed.zf.reveal.focusguard").on("closed.zf.reveal.focusguard", () => {
        $modal.off("closed.zf.reveal.focusguard");

        if ($(".reveal:visible", $container).length < 1) {
          $(`> .${focusGuardClass}`, $container).remove();
        }
      });

      // Check if the guards already exists due to some other dialog
      const $guards = $(`> .${focusGuardClass}`, $container);
      if ($guards.length > 0) {
        // Make sure the guards are the first and last element as there have
        // been changes in the DOM.
        $guards.each((_j, guard) => {
          const $guard = $(guard);
          if ($guard.data("position") === "start") {
            $container.prepend($guard);
          } else {
            $container.append($guard);
          }
        });

        return;
      }

      // Add guards at the start and end of the document and attach their focus
      // listeners
      const $startGuard = createFocusGuard("start");
      const $endGuard = createFocusGuard("end");

      $container.prepend($startGuard);
      $container.append($endGuard);

      $startGuard.on("focus", () => handleContainerFocus($container, $startGuard));
      $endGuard.on("focus", () => handleContainerFocus($container, $endGuard));
    });
  };
})(window);
