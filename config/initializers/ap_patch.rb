class ActionView::Helpers::InstanceTag
  def to_label_tag(text = nil, options = {})
    options = options.stringify_keys
    name_and_id = options.dup
    add_default_name_and_id(name_and_id)
    options.delete("index")
    options["for"] ||= name_and_id["id"]
    content = (text.blank? ? nil : text.to_s) || @object.class.human_attribute_name(method_name) || method_name.humanize
    label_tag(name_and_id["id"], content, options)
  end
end