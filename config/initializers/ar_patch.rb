class ActiveRecord::Errors
  def full_messages(options = {})
    full_messages = []

    @errors.each_key do |attr|
      @errors[attr].each do |message|
        full_messages << message if message
      end
    end
    full_messages
  end 
end
