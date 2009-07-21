class Partner < ActiveRecord::Base
  acts_as_authentic

  def self.find_by_login(login)
    find_by_username(login) || find_by_email(login)
  end

  def self.default_id
    1
  end

end
