module ApiHelperMethods
  def expect_api_response(data)
    mock(controller).jsonp(data)
  end

  def expect_api_error(data)
    mock(controller).jsonp(data, :status => 400)
  end
end