$(document).ready(function() {
  $.fn.qtip.styles.registrant = {
    name: 'blue',
    width: { max: '200px' },
    color: '#006',
    border: { width: 3, radius: 8 } // Rounded corners
  };

  addTooltips('.flat img.tooltip, .checkbox img.tooltip', 'topRight', 'bottomLeft');
  addTooltips('legend img.tooltip', 'rightMiddle', 'leftBottom');
});
