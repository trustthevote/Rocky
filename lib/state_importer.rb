class StateImporter
  def self.import(file)
    FasterCSV.new(file, :headers => true).each do |row|
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
    en.save!
    es = state.localizations.find_or_initialize_by_locale('es')
    es.not_participating_tooltip  = row["not_participating_tooltip_es"]
    es.race_tooltip               = row["race_tooltip_es"]
    es.party_tooltip              = row["party_tooltip_es"]
    es.parties                    = read_parties(row["parties_es"])
    es.no_party                   = row["no_party_es"]
    es.id_number_tooltip          = row["id_number_tooltip_es"]
    es.save!
  end

  def self.read_parties(raw)
    raw ? raw.split(',').collect {|s| s.strip} : []
  end
end
