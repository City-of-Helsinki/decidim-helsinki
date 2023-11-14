import Splide from "@splidejs/splide";

const sliderI18n = {
  fi: {
    carousel: "karuselli",
    prev: "Edellinen sivu",
    next: "Seuraava sivu",
    first: "Siirry ensimmäiselle sivulle",
    last: "Siirry viimeiselle sivulle",
    slideX: "Siirry kohtaan %s",
    pageX: "Siirry sivulle %s",
    play: "Vieritä automaattisesti",
    pause: "Pysäytä automaattinen vieritys",
    select: "Valitse näytettävä sivu",
    slide: "sivu",
    slideLabel: "%s / %s"
  },
  sv: {
    carousel: "carousel",
    prev: "Föregående sida",
    next: "Nästa sida",
    first: "Gå till första sidan",
    last: "Gå till sista sidan",
    slideX: "Gå till sidan %s",
    pageX: "Gå till sidan %s",
    play: "Starta automatisk uppspelning",
    pause: "Pausa automatisk uppspelning",
    select: "Välj sidan som ska visas",
    slide: "sida",
    slideLabel: "%s / %s"
  },
  en: {
    carousel: "karusell",
    prev: "Previous page",
    next: "Next page",
    first: "Go to first page",
    last: "Go to last page",
    slideX: "Go to slide %s",
    pageX: "Go to page %s",
    play: "Start autoplay",
    pause: "Pause autoplay",
    select: "Select a slide to show",
    slide: "slide",
    slideLabel: "%s of %s"
  }
};

const createOptions = (original, totalSlides, extra = {}) => {
  const stateOptions = {
    enabled: {
      drag: true,
      arrows: true
    },
    disabled: {
      drag: false,
      arrows: false
    }
  };
  const options = { ...original, ...extra };

  if (totalSlides <= options.perPage) {
    return {...options, ...stateOptions.disabled};
  }
  return {...options, ...stateOptions.enabled};
};

/**
 * This class serves as a layer on top of the underlying slider class in order
 * to add extra functionality to it and slight customizations, such as the
 * pagination counter and custom initialization and destroy functionality.
 *
 * The slider DOM changes its shape when the slider is initialized and it is
 * reverted back to original when the slider is destroyed. This maintains the
 * layout rows and columns instead of breaking the column layout.
 */
class Slider {
  constructor(element, options) {
    this.element = element;

    [this.customOptions, this.splideOptions] = this._splitOptions(options);
    delete this.customOptions.breakpoints;
    this.customOptions = { 0: this.customOptions };

    const bpOptions = this.splideOptions.breakpoints || {};
    Object.keys(bpOptions).forEach((breakpoint) => {
      const [customBpOptions, splideBpOptions] = this._splitOptions(bpOptions[breakpoint]);
      this.customOptions[breakpoint] = customBpOptions;
      this.splideOptions.breakpoints[breakpoint] = splideBpOptions;
    });

    this.breakpoints = Object.keys(this.customOptions).map((val) => parseInt(val)).sort();

    this.available = false;
    this._setBreakpoint();
    this._breakpointChange();
    this._initialize();
  }

  _splitOptions(options) {
    const { adjustHeight, destroy, ...splideOptions } = options;
    return [{ adjustHeight: adjustHeight, destroy: destroy }, splideOptions];
  }

  _setBreakpoint() {
    this.currentBreakpoint = 0;
    this.breakpoints.forEach((breakpoint) => {
      const match = window.matchMedia(`(min-width:${breakpoint}px)`);
      if (match.matches) {
        this.currentBreakpoint = breakpoint;
      }
    });

    this.currentOptions = this.customOptions[this.currentBreakpoint];
  }

  _breakpointChange() {
    this.currentOptions = this.customOptions[this.currentBreakpoint];
    if (this.available && this.currentOptions.destroy) {
      this._destroy();
    }
  }

  _initialize() {
    if (this.currentOptions.destroy) {
      this.available = false;

      let resizing = false;
      const resizeListener = () => {
        if (resizing) {
          return;
        }

        const prevBreakpoint = this.currentBreakpoint;
        this._setBreakpoint();

        if (prevBreakpoint !== this.currentBreakpoint && !this.currentOptions.destroy) {
          window.removeEventListener("resize", resizeListener);
          this._initialize();
        }
      }
      window.addEventListener("resize", resizeListener);

      return;
    }
    if (this.available) {
      return;
    }

    this._convertToSlider();

    this.splide = new Splide(this.element, this.splideOptions);
    this.splide.mount();

    // Fix some markup
    this.splide.root.querySelectorAll(".splide__slide--clone").forEach((clone) => {
      const fc = clone.querySelector("[id^='favoriting_count_']");
      if (fc) {
        fc.removeAttribute("id");
      }
    });

    const pagination = this._createSliderPagination();
    this.splide.root.appendChild(pagination);
    this._adjustHeight();
    this._updatePagination();

    let disableUpdate = false;
    this.splide.on("move", () => {
      this._updatePagination();
      this._adjustHeight();
    });
    this.splide.on("updated", () => {
      // When the options are updated, this event is emitted again which means
      // that this would be called indefinitely if we did not temporarily
      // disable the event.
      if (disableUpdate) {
        return;
      }
      disableUpdate = true;

      this._updatePagination();

      disableUpdate = false;
    });
    this.splide.on("resized", () => {
      const prevBreakpoint = this.currentBreakpoint;

      this._setBreakpoint();
      this._adjustHeight();

      if (prevBreakpoint !== this.currentBreakpoint) {
        this._breakpointChange();
      }
    });

    this.available = true;
  }

  _destroy() {
    this.splide.destroy(true);
    delete this.splide;

    this.element.classList.remove("splide", "is-initialized");
    if (this.wasRow) {
      this.element.classList.add("row");
      this.wasRow = false;
    }

    this.element.querySelectorAll(".splide__track .splide__list .splide__slide").forEach((slide) => {
      slide.setAttribute("class", slide.getAttribute("data-slide-class"));
      slide.removeAttribute("data-slide-class");
      slide.removeAttribute("id");

      this.element.appendChild(slide);
    });

    this.element.querySelector(".splide__track").remove();
    this.element.querySelector(".splide__numpagination").remove();

    // Call initialize to set the resize listener to figure out whether the
    // slider needs to be re-initialized at a specific breakpoint.
    this._initialize();
  }

  _convertToSlider() {
    // Convert the grid presentation to a slider
    const track = document.createElement("div");
    track.classList.add("splide__track");

    const list = document.createElement("div");
    list.classList.add("splide__list");
    track.appendChild(list);

    [...this.element.children].forEach((node) => {
      if (node.hasAttribute("class")) {
        node.setAttribute("data-slide-class", node.getAttribute("class"));
      }
      node.setAttribute("class", "splide__slide");
      list.appendChild(node);
    });

    if (this.element.classList.contains("row")) {
      this.wasRow = true;
      this.element.classList.remove("row");
    } else {
      this.wasRow = false;
    }

    this.element.classList.add("splide");
    this.element.appendChild(track);
  }

  _createSliderPagination() {
    const wrapper = document.createElement("div");
    wrapper.className = "splide__numpagination";
    wrapper.innerHTML = `
      <span class="splide__numpagination__current"></span>
      <span class="splide__numpagination__separator">/</span>
      <span class="splide__numpagination__total"></span>
    `;

    return wrapper;
  }

  _adjustHeight() {
    const list = this.splide.root.querySelector(".splide__list");
    if (!this.currentOptions.adjustHeight) {
      list.style.maxHeight = "unset";
      return;
    }

    const { perPage } = this.splide.options;
    const currentIndex = this.splide.index;

    // Determine the heights of the visible items
    const heights = [];
    list.querySelectorAll(".splide__slide:not(.splide__slide--clone)").forEach((slide, ind) => {
      if (ind < currentIndex) {
        return;
      } else if (ind + 1 > currentIndex + perPage) {
        return;
      }

      slide.style.alignSelf = "flex-start";
      heights.push(slide.offsetHeight);
      slide.style.alignSelf = null;
    });

    const maxHeight = Math.max(...heights);
    list.style.maxHeight = `${Math.ceil(maxHeight)}px`;
  }

  _updatePagination() {
    const pagination = this.splide.root.querySelector(".splide__numpagination");
    if (!pagination) {
      return;
    }

    const { perPage } = this.splide.options;

    let current = Math.floor(this.splide.index / perPage) + 1;
    const total = Math.ceil(this.splide.length / perPage);
    if (this.splide.index + perPage === this.splide.length) {
      // The last page can be smaller in case there is uneven number of items
      current = total;
    }

    pagination.querySelector(".splide__numpagination__current").innerText = current;
    pagination.querySelector(".splide__numpagination__total").innerText = total;
  }
}

const createSliders = (container) => {
  const lang = document.querySelector("html").getAttribute("lang") || "en";

  const defaultOptions = {
    i18n: sliderI18n[lang],
    type: "loop",
    pagination: false,
    // HDS arrow-right scaled to 40px width and vertically centered
    arrowPath: "M 24.242424,4.242424 20.606061,7.8787876 30.30303,17.575757 H 0 v 4.848485 h 30.30303 l -9.696969,9.69697 3.636363,3.636364 L 40,20 Z",
    perPage: 1,
    gap: "1rem",
    mediaQuery: "min"
  };
  const breakpointOptions = {
    medium: {
      perPage: 2,
      gap: "1.5rem"
    },
    large: {
      perPage: 3,
      gap: "1.5rem"
    }
  };
  const breakpointSizes = {
    medium: 768,
    large: 992
  };

  container.querySelectorAll("[data-slide]").forEach((sliderEl) => {
    // Determine the enabled / disabled state from the amount of slides compared
    // to the slides per page option.
    const sliderOptions = JSON.parse(sliderEl.getAttribute("data-slide") || "{}");
    const sliderBpOptions = sliderOptions.breakpoints || {};
    delete sliderOptions.breakpoints;

    const totalSlides = sliderEl.children.length;
    const options = { ...createOptions(defaultOptions, totalSlides, sliderOptions), breakpoints: {} };
    Object.keys(breakpointOptions).forEach((key) => {
      const size = breakpointSizes[key];
      options.breakpoints[size] = createOptions(breakpointOptions[key], totalSlides, sliderBpOptions[key]);
    });

    sliderEl.slider = new Slider(sliderEl, options);
  });
};

export default (container) => {
  createSliders(container);
};
