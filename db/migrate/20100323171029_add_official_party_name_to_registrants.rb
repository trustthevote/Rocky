class AddOfficialPartyNameToRegistrants < ActiveRecord::Migration

  class StateLocalization < ActiveRecord::Base
    serialize :parties
  end
  class Registrant < ActiveRecord::Base
    def set_official_party_name!
      return unless self.status == "step_5" || self.status == "complete"
      self.official_party_name =
        if party.blank?
          "None"
        else
          en_loc = StateLocalization.find(:first, :conditions => {:state_id  => home_state_id, :locale => "en"})
          case self.locale
            when "en"
              party == en_loc.no_party ? "None" : party
            when "es"
              es_loc = StateLocalization.find(:first, :conditions => {:state_id  => home_state_id, :locale => "es"})
              if party == es_loc.no_party
                "None"
              else
                en_loc[:parties][ es_loc[:parties].index(party) ]
              end
            end
        end
      self.save!
    end
  end

  def self.up
    add_column "registrants", "official_party_name", :string
    add_index  "registrants", "official_party_name"
    
    Registrant.find_each { |r| r.set_official_party_name! }
  end

  def self.down
    remove_index  "registrants", "official_party_name"
    remove_column "registrants", "official_party_name"
  end
end
