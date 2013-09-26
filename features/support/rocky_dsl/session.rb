module RockyDsl
  class Capybara::Session
    def has_image?(image_url)
      self.all("img[src='#{image_url}']").count > 0
    end

    def has_checkbox?(field_label)
      has_field?(field_label)
    end
  
  private
    def object_finder(obj_name, opts)
      css_selector = "#{opts[:within]} #{opts[:tag_name]}.#{obj_name}".strip
      self.all(css_selector)
    end
  end
end