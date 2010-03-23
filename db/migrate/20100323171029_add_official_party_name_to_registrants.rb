class AddOfficialPartyNameToRegistrants < ActiveRecord::Migration

  class StateLocalization < ActiveRecord::Base
    serialize :parties
  end
  class GeoState < ActiveRecord::Base
    has_many :localizations, :class_name => 'AddOfficialPartyNameToRegistrants::StateLocalization', :foreign_key => 'state_id'
  end
  class Registrant < ActiveRecord::Base
    belongs_to :home_state,    :class_name => "AddOfficialPartyNameToRegistrants::GeoState"
    has_many  :localizations, :through => :home_state,
              :class_name => 'AddOfficialPartyNameToRegistrants::StateLocalization',
              :autosave => false do
      def by_locale(loc)
        find_by_locale(loc.to_s)
      end
    end
    def set_official_party_name!
      return if party.blank?
      self.official_party_name = case self.locale
        when "en"
          party
        when "es"
          en_loc = localizations.by_locale(:en)
          es_loc = localizations.by_locale(:es)
          if party == es_loc.no_party
            en_loc.no_party
          else
            en_loc[:parties][ es_loc[:parties].index(party) ]
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
