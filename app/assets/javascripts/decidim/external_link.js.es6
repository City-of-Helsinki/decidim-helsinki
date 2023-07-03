/**
 * This is overriden from Decidim core because of few improvements:
 * 1. Adds the possibility to define a custom spacer not to force it to be
 *    "&nbsp;"
 * 2. Adds the possibility to define a custom target element for the indicator
 *    within the link element
 * 3. Fixes a bug regarding the &nbsp; spacer with image links
 */
((exports) => {
  const { icon } = exports.Decidim;

  const EXCLUDE_CLASSES = [
    "card--list__data__icon",
    "footer-social__icon",
    "logo-cityhall"
  ];
  const EXCLUDE_REL = ["license", "decidim"];

  const DEFAULT_MESSAGES = {
    externalLink: "External link"
  };
  let MESSAGES = DEFAULT_MESSAGES;

  class ExternalLink {
    static configureMessages(messages) {
      MESSAGES = exports.$.extend(DEFAULT_MESSAGES, messages);
    }

    constructor(link) {
      this.$link = link;

      this.setup();
    }

    setup() {
      if (EXCLUDE_CLASSES.some((cls) => this.$link.hasClass(cls))) {
        return;
      }
      if (
        EXCLUDE_REL.some((rel) => {
          const linkRels = `${this.$link.attr("rel")}`.split(" ");
          return linkRels.indexOf(rel) > -1;
        })
      ) {
        return;
      }

      this.$link.addClass("external-link-container");
      let spacer = "&nbsp;";
      if (this.$link[0].hasAttribute("data-external-link-spacer")) {
        spacer = this.$link.data("external-link-spacer");
      } else if (this.$link.text().trim().length < 1) {
        // Fixes image links extra space
        spacer = "";
      }

      let $target = this.$link;
      if (this.$link[0].hasAttribute("data-external-link-target")) {
        $target = $(this.$link.data("external-link-target"), this.$link);
      }
      $target.append(`${spacer}${this.generateElement()}`);
    }

    generateElement() {
      let content = `${this.generateIcon()}${this.generateScreenReaderLabel()}`;

      return `<span class="external-link-indicator">${content}</span>`;
    }

    generateIcon() {
      return icon("external-link");
    }

    generateScreenReaderLabel() {
      return `<span class="show-for-sr">(${MESSAGES.externalLink})</span>`;
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.ExternalLink = ExternalLink;

  $(document).ready(function() {
    $('a[target="_blank"]').each((_i, elem) => {
      const $link = $(elem);

      $link.data("external-link", new ExternalLink($link));
    });
  });
})(window);
