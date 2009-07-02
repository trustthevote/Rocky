class Registrant < ActiveRecord::Base

  attr_protected :status

  include AASM
  aasm_column :status
  aasm_initial_state :blank
  aasm_state :blank
  aasm_state :step_1
  aasm_state :step_2
  aasm_state :step_3
  aasm_state :complete
  
  with_options :if => :at_least_step_1? do |reg|
    reg.validates_presence_of :name_title
    reg.validates_presence_of :first_name
    reg.validates_presence_of :last_name
    reg.validates_presence_of :email_address
    reg.validates_presence_of :home_zip_code
    reg.validates_presence_of :date_of_birth
  end

  with_options :if => :at_least_step_2? do |reg|
    reg.validates_acceptance_of :us_citizen, :message => "You must be a U.S. citizen to register to vote."
    reg.validates_presence_of :home_address
    reg.validates_presence_of :home_city
    reg.validates_presence_of :home_state
  end

  STEPS = [:blank, :step_1, :step_2, :step_3, :complete]

  def at_least_step_1?
    at_least_step?(1)
  end

  def at_least_step_2?
    at_least_step?(2)
  end

  aasm_event :advance_to_step_1 do
    transitions :to => :step_1, :from => [:blank]
  end

  # aasm_event :complete_step_1 { transitions :to => :step_1, :from => [:blank] }


  # def advance_to!(next_step, new_attributes = {})
  #   self.attributes = new_attributes
  #   current_status_number = STEPS.index(aasm_current_state)
  #   next_status_number = STEPS.index(next_step)
  #   status_number = [current_status_number, next_status_number].max
  #   send("advance_to_#{STEPS[status_number]}!")
  # end



  # %w(home mailing).each do |location|
  #   validates_presence_of "#{location}_address"
  #   validates_presence_of "#{location}_city"
  #   validates_presence_of "#{location}_state"
  # end

  private

  def at_least_step?(step)
    STEPS.index(aasm_current_state) >= step
  end

end
