$(document).ready(function() {
  
  $(".setting li select").change(function () {
    var key = this.value;
    console.log("Key: " + key);
    var option = $(this).parent().find(".values ." + key)
    
    console.log(option.text());
    var json_values = JSON.parse(option.text());
    for(var lang_name in json_values) {
      console.log(lang_name);
      console.log(json_values[lang_name]);
      var optionDisplay = $(this).parent().find(".locale_"+lang_name+" .translation");
      optionDisplay.text(json_values[lang_name]);
    }
  });
  
  $(".setting h2").click(function() {
		$(this).parent().children("ul").toggle();
	});
	
	$(".setting h2").click();

  $(".languages ul li span.collapsable").click(function() {
    $(this).toggleClass('collapsed')
    $(this).parent().children("ul").toggle();
  });

  
});