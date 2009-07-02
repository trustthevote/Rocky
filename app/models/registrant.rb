class Registrant < ActiveRecord::Base
  include AASM
  aasm_column :status
  aasm_initial_state :blank
  aasm_state :blank
  aasm_state :step_1
  aasm_state :step_2
  aasm_state :step_3
  aasm_state :complete
  
  validates_presence_of :name_title
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email_address
  validates_presence_of :home_zip_code
  validates_presence_of :date_of_birth

  with_options :if => :past_step_1? do |reg|
    reg.validates_acceptance_of :us_citizen, :message => "You must be a U.S. citizen to register to vote."
    reg.validates_presence_of :home_address
    reg.validates_presence_of :home_city
    reg.validates_presence_of :home_state
  end

  def past_step_1?
    aasm_current_state != :blank
  end

  aasm_event :complete_step_1 do
    transitions :to => :step_1, :from => [:blank]
  end

  # aasm_event :complete_step_1 { transitions :to => :step_1, :from => [:blank] }





  # %w(home mailing).each do |location|
  #   validates_presence_of "#{location}_address"
  #   validates_presence_of "#{location}_city"
  #   validates_presence_of "#{location}_state"
  # end
end
