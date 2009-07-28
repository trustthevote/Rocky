function toggleFieldSet(checkbox, set, rule, speed) {
  if ( $(checkbox).attr('checked') ) {
    $(rule).hide(0);
    $(set).fadeIn(speed);
  } else {
    $(set).fadeOut(speed);
    $(rule).show(0);
  }
}

function checkboxTogglesSet(checkbox, set, rule) {
  toggleFieldSet(checkbox, set, rule, 0);
  $(checkbox).change(function () {
    toggleFieldSet(checkbox, set, rule, 'fast');
  });
}
