/**
 * This fixes the resource page content height on medium (and up) sized screens
 * since the CSS of that page is hacky due to the structural constraints of the
 * page. Due to the structural constraints, the sidebar height is always "0" on
 * medium (and up) sized screens. This requires the content column to have a
 * min-height assuming a specific sidebar height. Sometimes this assumption is
 * incorrect which causes too large gap between the content and the comments
 * element.
 *
 * This script fixes that issue by applying the exact sidebar height as the
 * content section's min-height.
 */

// This is the "medium" breakpoint after which the min-heights are applied.
// Below this screen size, the min-height should not be applied.
const applyHeightBreakpoint = 768;

/**
 * Calculates the height of element children because
 * (a) the sidebar is "suppressed" to 0, so it does not have height in the eyes
 *     of the browser
 * (b) the content section has a min-height on larger breakpoints forcing it to
 *     specific height regardless of the actual content height
 *
 * This is due to the structural constraints of the page, i.e. in which order we
 * want the elements to appear.
 *
 * @param {HTMLElement} element The element for which to calculate the height.
 * @returns {Number} The height of all children and their applied margins.
 */
const calculateChildrenHeight = (element) => {
  let height = 0;
  let prevStyle = null;
  for (let ch of element.children) {
    const style = window.getComputedStyle(ch);
    let marginTop = parseFloat(style.marginTop);
    if (prevStyle) {
      marginTop = Math.max(marginTop, parseFloat(prevStyle.marginTop));
    }
    height += ch.offsetHeight + marginTop + parseFloat(style.marginBottom);

    prevStyle = style;
  }
  return Math.round(height);
}

const applyHeight = () => {
  const main = document.querySelector(".resource__main");
  const aside = document.querySelector(".resource__aside");
  const content = document.querySelector(".resource__content");
  if (!main || !aside || !content) {
    return;
  }

  const match = window.matchMedia(`(min-width:${applyHeightBreakpoint}px)`);
  if (match.matches) {
    const sidebarHeight = calculateChildrenHeight(aside) - main.offsetHeight;
    content.style.setProperty("min-height", `${sidebarHeight}px`);

    console.log(content);
  } else {
    content.style.removeProperty("min-height");
  }
};

export default () => {
  applyHeight();

  let to = null;
  window.addEventListener("resize", () => {
    clearTimeout(to);
    to = setTimeout(() => {
      applyHeight();
    }, 200);
  });
}
