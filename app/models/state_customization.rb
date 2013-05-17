class StateCustomization
  
  attr_accessor :state
  
  def self.for(state)
    klass = class_exists?(state.abbreviation) ?  state.abbreviation.constantize : self
    klass.new(state)
  end
  
  def initialize(state)
    @state = state
  end
  
  def online_reg_url(registrant)
    state.online_registration_url
  end
  
protected
  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
  rescue NameError
    return false
  end
  
end