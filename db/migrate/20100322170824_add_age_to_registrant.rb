class AddAgeToRegistrant < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
    def calculate_age!
      now = created_at.to_date
      years = now.year - date_of_birth.year
      if (date_of_birth.month > now.month) || (date_of_birth.month == now.month && date_of_birth.day > now.day)
        years -= 1
      end
      self.update_attributes!(:age => years)
    end
  end

  def self.up
    add_column "registrants", "age", :integer

    Registrant.find_each { |r| r.calculate_age! }
  end

  def self.down
    remove_column "registrants", "age"
  end
end
