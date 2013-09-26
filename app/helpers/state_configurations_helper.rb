module StateConfigurationsHelper
  def defaults_used_by_state(state_key_values)
    @defaults.each do |key, value|
      if !state_key_values.include?(key)
        yield key, value
      end
    end
  end
  
  def key_has_default(key, state)
     @defaults.has_key?(key) && state_not_default(state)
  end
  
  def state_not_default(state)
    state != 'defaults'
  end
end