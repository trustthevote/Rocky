class UrlFormatValidator < ActiveModel::EachValidator

  BASIC_REGEX = /^https?:\/\/([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/

  def validate_each(object, attribute, value)
    return true if value.blank?
    regex = BASIC_REGEX
    message = :url_format
    if valid_types.include?(options[:type])
      regex = domain_specific_regex(options[:type])
      message = :"#{options[:type]}_url_format"
    end
    
    if !(value =~ regex)
      object.errors.add(attribute, message)
    end
  end
  
private
  def valid_types
    [:facebook, :twitter, :meetup, :eventbrite]
  end
  
  def domain_specific_regex(domain)
    case domain
    when :eventbrite
      /^https?:\/\/[a-z\d-]*\.?eventbrite\.com/i
    else
      /^https?:\/\/(www\.)?#{domain}\.com\/.+/i
    end
  end
  
end