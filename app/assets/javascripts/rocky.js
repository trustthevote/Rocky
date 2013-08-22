function hideErrors() {
  $('.error').each(function(){ $(this).css('opacity', 0); });
};

function revealErrors() {
  $('.error').each(function() { $(this).animate({opacity: 1}); });
};

function toggleFieldSet(checkbox, set, rule, speed) {
	console.log(checkbox, set, rule, speed)
  if ( $(checkbox).is(':checked') ) {
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
			classes: 'qtip-blue qtip-rounded'
		},
    position: {
      at: target_corner,
      my: tooltip_corner,
			viewport: $(window)
    },
    hide: { fixed: true, delay: 300, effect: { length: 50 } }, // Hovering over tooltip keeps them visible
    show: { delay: 50, effect: { length: 50 } }
  })
};
