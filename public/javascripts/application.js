function toggleFieldSet(checkbox, set, rule, speed) {
  if ( $(checkbox).attr('checked') ) {
    $(rule).hide(0);
    $(set).fadeIn(speed);
  } else {
    $(set).fadeOut(speed);
    $(rule).show(0);
  }
};

function checkboxTogglesSet(checkbox, set, rule) {
  toggleFieldSet(checkbox, set, rule, 0);
  $(checkbox).change(function () {
    toggleFieldSet(checkbox, set, rule, 'fast');
  });
};

function addTooltips(selector, target_corner, tooltip_corner) {
  $(selector).qtip({
    style: {
      name: 'registrant',
      tip: tooltip_corner
    },
    position: {
      corner: {
        target: target_corner,
        tooltip: tooltip_corner
      },
      adjust: { screen: true } // Change positioning if tooltip would be offscreen.
    },
    hide: { fixed: true, delay: 300, effect: { length: 50 } }, // Hovering over tooltip keeps them visible
    show: { effect: { length: 50 } }
  })
};
