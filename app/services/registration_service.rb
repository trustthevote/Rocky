class RegistrationService

  # Validation error
  class ValidationError < StandardError
    attr_reader :field

    def initialize(field, message)
      super(message)
      @field = field
    end
  end

  # Unsupported language error
  class UnsupportedLanguage < StandardError
    def initialize
      super 'Unsupported language'
    end
  end

  # Creates a record and returns it.
  def self.create_record(data)
    attrs = data_to_attrs(data)
    reg = Registrant.build_from_api_data(attrs)

    if reg.save
      reg.generate_pdf
    else
      validate_language(reg)
      raise_validation_error(reg)
    end

    reg
  end

  private

  def self.validate_language(reg)
    raise UnsupportedLanguage if reg.errors.on(:locale)
  end

  def self.raise_validation_error(reg)
    error = reg.errors.sort.first
    raise ValidationError.new(error.first, error.last)
  end

  def self.data_to_attrs(data)
    attrs = data.clone
    attrs[:locale] = attrs.delete(:lang)
    attrs
  end

end
