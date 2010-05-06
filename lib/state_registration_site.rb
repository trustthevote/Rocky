require "mechanize"

class StateRegistrationSite
  def initialize(registrant)
    @registrant = registrant
  end

  def transfer
    host = 'www.sos.state.co.us'
    secure_intro_path = '/Voter/secuRegVoterIntro.do'
    verify_path = '/Voter/verifyExist.do'
    success_path_re = %r{/Voter/editVoterDetails\.do}
    agent = Mechanize.new

    # secure intro
    page = agent.get("https://#{host}#{secure_intro_path}")

    # get form page
    page = agent.get("https://#{host}#{verify_path}")

    # post form
    voter_form = page.form("NewVoterForm")
    voter_form.VoterName_lastName   = @registrant.last_name
    voter_form.VoterName_firstName  = @registrant.first_name
    voter_form.VoterName_middleName = @registrant.middle_name
    voter_form.VoterName_suffixName = @registrant.name_suffix
    voter_form.birthDateAsString    = @registrant.date_of_birth.strftime("%m/%d/%Y")
    voter_form.driverLic            = @registrant.state_id_number
    page = agent.submit(voter_form, voter_form.buttons.first)

    url = agent.current_page.uri.to_s
    url =~ success_path_re ? url : nil
  end
end
