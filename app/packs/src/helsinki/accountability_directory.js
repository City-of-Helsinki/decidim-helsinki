export default (container) => {
  container.querySelectorAll(".results-table__row").forEach((el) => {
    const clickableArea = el.querySelector(".results-table__row__data");
    const button = clickableArea.querySelector(".results-table__row__button")
    const clickHandler = (ev) => {
      ev.preventDefault();

      if (el.dataset.showDetails) {
        el.removeAttribute("data-show-details");
        button.setAttribute("aria-expanded", false);
      } else {
        el.setAttribute("data-show-details", true);
        button.setAttribute("aria-expanded", true);
      }
    }

    clickableArea.addEventListener("click", clickHandler);
    button.addEventListener("keydown", (ev) => {
      if (ev.code === "Enter" || ev.code === "Space") {
        clickHandler(ev);
      }
    });
  });
};
