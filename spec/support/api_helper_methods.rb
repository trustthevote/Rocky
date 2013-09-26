module ApiHelperMethods
  def expect_api_response(data)
    controller.stub(:jsonp).with(data) { controller.render :nothing=>true }
  end

  def expect_api_error(data)
    controller.stub(:jsonp).with(data, :status => 400)  { controller.render :nothing=>true }
  end
end