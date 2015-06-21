var editPartnerForm = function() {
  var f = $("form.edit_partner");
  if (f.length == 0) return;

  var wlBlock = $("div.whitelabeled"),
      wl = $("input#partner_whitelabeled");

  var update = function() {
    if (wl.is(":checked")) wlBlock.show(); else wlBlock.hide();
  }

  wl.change(update);
  update();
}

var emailTemplateUI = function() {
    $(".locale-select").change(function() {
        $(".email-template").hide();
        var loc = this.value;
        console.log(loc);
        $(".email-template-"+loc).show();
    })
    $(".locale-select").change();
}


$(function() {
  editPartnerForm();
  emailTemplateUI();
});

