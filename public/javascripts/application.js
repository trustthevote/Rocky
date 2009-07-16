function toggleFieldSet(checkbox, set, speed) {
  if ( $(checkbox).attr('checked') ) {
    $(set).show(speed);
  } else {
    $(set).hide(speed);
  }
}

function checkboxTogglesSet(checkbox, set) {
  toggleFieldSet(checkbox, set, 0);
  $(checkbox).change(function () {
    toggleFieldSet(checkbox, set, 'fast');
  });
}
