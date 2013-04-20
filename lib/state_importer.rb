#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
class StateImporter
  def self.import(file)
    CSV.new(file, :headers => true).each do |row|
      begin
        print "#{row['name']}... "
        import_state(row)
        import_localizations(row)
        puts "DONE!"
      rescue StandardError => e
        $stderr.puts "!!! could not import state data for #{row['name']}"
        $stderr.puts e.message
        $stderr.puts e.backtrace
      end
    end
  end

  def self.import_state(row)
    state = GeoState[row["abbreviation"]]

    state.name = row["name"]
    state.participating = row["participating"]
    state.requires_race = row["requires_race"]
    state.requires_party = row["requires_party"]
    state.id_length_min = row["id_length_min"]
    state.id_length_max = row["id_length_max"]
    state.registrar_address = row["sos_address"]
    state.registrar_phone = row["sos_phone"]
    state.registrar_url = row["sos_url"]
    state.save!
  end

  def self.import_localizations(row)
    state = GeoState[row["abbreviation"]]
    en = state.localizations.find_or_initialize_by_locale('en')
    en.not_participating_tooltip  = row["not_participating_tooltip_en"]
    en.race_tooltip               = row["race_tooltip_en"]
    en.party_tooltip              = row["party_tooltip_en"]
    en.parties                    = read_parties(row["parties_en"])
    en.no_party                   = row["no_party_en"]
    en.id_number_tooltip          = row["id_number_tooltip_en"]
    en.sub_18                     = row["sub_18_en"]
    en.save!
    es = state.localizations.find_or_initialize_by_locale('es')
    es.not_participating_tooltip  = row["not_participating_tooltip_es"]
    es.race_tooltip               = row["race_tooltip_es"]
    es.party_tooltip              = row["party_tooltip_es"]
    es.parties                    = read_parties(row["parties_es"])
    es.no_party                   = row["no_party_es"]
    es.id_number_tooltip          = row["id_number_tooltip_es"]
    es.sub_18                     = row["sub_18_es"]
    es.save!
  end

  def self.read_parties(raw)
    raw ? raw.split(',').collect {|s| s.strip} : []
  end
end
