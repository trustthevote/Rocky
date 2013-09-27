class PdfRenderer < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  helper ApplicationHelper
  
  self.view_paths = "app/views"
  
  attr_accessor :registrant
  attr_accessor :state
  
  def registrant=(value)
    @registrant  = value
    set_registrant_instructions_link
  end
  
  def set_registrant_instructions_link
    url = self.registrant.registration_instructions_url
    @registrant_instructions_link = link_to url, url
  end
  
end