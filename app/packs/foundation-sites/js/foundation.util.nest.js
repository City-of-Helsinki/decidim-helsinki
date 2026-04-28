import $ from 'jquery';

/**
 * OVERRIDDEN
 * This file is overridden to fix the `role="none"` attributes.
 *
 * This also disables the `aria-expanded` attribute on the drilldown items
 * because it is not a correct ARIA attribute on the presentational `<li>`
 * element.
 */
const Nest = {
  Feather(menu, type = 'zf') {
    menu.attr('role', 'menubar');
    menu.find('a').attr({'role': 'menuitem'});

    var items = menu.find('li').attr({'role': 'presentation'}),
        subMenuClass = `is-${type}-submenu`,
        subItemClass = `${subMenuClass}-item`,
        hasSubClass = `is-${type}-submenu-parent`,
        applyAria = (type !== 'accordion'); // Accordions handle their own ARIA attriutes.

    items.each(function() {
      var $item = $(this),
          $sub = $item.children('ul');

      if ($sub.length) {
        $item.addClass(hasSubClass);
        if(applyAria) {
          const firstItem = $item.children('a:first');
          firstItem.attr({
            'aria-haspopup': true,
            'aria-label': firstItem.attr('aria-label') || firstItem.text()
          });
          // Note:  Drilldowns behave differently in how they hide, and so need
          // additional attributes.  We should look if this possibly over-generalized
          // utility (Nest) is appropriate when we rework menus in 6.4
          if(type === 'drilldown') {
            $item.attr({'data-drilldown-expanded': false});
          }
        }
        $sub
          .addClass(`submenu ${subMenuClass}`)
          .attr({
            'data-submenu': '',
            'role': 'menubar'
          });
        if(type === 'drilldown') {
          $sub.attr({'aria-hidden': true});
        }
      }

      if ($item.parent('[data-submenu]').length) {
        $item.addClass(`is-submenu-item ${subItemClass}`);
      }
    });

    return;
  },

  Burn(menu, type) {
    var //items = menu.find('li'),
        subMenuClass = `is-${type}-submenu`,
        subItemClass = `${subMenuClass}-item`,
        hasSubClass = `is-${type}-submenu-parent`;

    menu
      .find('>li, > li > ul, .menu, .menu > li, [data-submenu] > li')
      .removeClass(`${subMenuClass} ${subItemClass} ${hasSubClass} is-submenu-item submenu is-active`)
      .removeAttr('data-submenu').css('display', '');

  }
}

export {Nest};
