/**
 * Announces a message to the screen reader dynamically.
 *
 * This should not be called consecutively multiple times because the screen
 * reader may not read all the messages if the content is changed quickly.
 *
 * This method came to existence when implementing a notification for screen
 * readers when the form reset buttons are clicked. After that, it was requested
 * to add a screen reader message for the fields that add markers on maps.
 * Eventually the original implementation was ported to Decidim 0.29 (?) through
 * this PR:
 * https://github.com/decidim/decidim/pull/12707
 *
 * This is a backport of the method from that PR.
 *
 * @param {String} message The message to be announced
 * @param {String} mode The mode for the announcement, either "assertive"
 *   (default) or "polite".
 * @return {void}
 */
const announceForScreenReader = (message, mode = "assertive") => {
  if (!message || typeof message !== "string" || message.length < 1) {
    return;
  }

  let element = document.getElementById("screen-reader-announcement");
  if (!element) {
    element = document.createElement("div");
    element.setAttribute("id", "screen-reader-announcement");
    element.classList.add("sr-only");
    element.setAttribute("aria-atomic", true);
    document.body.append(element);
  }
  if (mode === "polite") {
    element.setAttribute("aria-live", mode);
  } else {
    element.setAttribute("aria-live", "assertive");
  }

  element.innerHTML = "";

  setTimeout(() => {
    // Wrap the text in a span with a random attribute value that changes every
    // time to try to indicate to the screen reader the content has changed. This
    // helps reading the message aloud if the message is exactly the same as the
    // last time.
    const randomIdentifier = `announcement-${new Date().getUTCMilliseconds()}-${Math.floor(Math.random() * 10000000)}`;
    const announce = document.createElement("span")
    announce.setAttribute("data-random", randomIdentifier);
    announce.textContent = message;
    element.append(announce);
  }, 100);
};

export { announceForScreenReader };
