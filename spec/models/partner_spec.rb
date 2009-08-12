require File.dirname(__FILE__) + '/../spec_helper'

describe Partner do
  describe "#primary?" do
    it "is true for primary partner" do
      assert Partner.find(Partner.default_id).primary?
    end

    it "is false for non-primary partner" do
      assert !Factory.build(:partner).primary?
    end
  end

  describe "#logo_image_url" do
    it "is saved for non-primary partner" do
      url = "http://example.com/logo.jpg"
      assert_equal url, Factory.create(:partner, :logo_image_url => url).logo_image_url
    end
    it "is local for primary partner" do
      assert_match /^reg/, Partner.find(Partner.default_id).logo_image_url
    end
  end

  describe "CSV" do
    it "can generate CSV of all registrants" do
      partner = Factory.create(:partner)
      registrants = []
      3.times { registrants << Factory.create(:maximal_registrant, :partner => partner) }
      registrants << Factory.create(:step_1_registrant, :partner => partner)

      other_partner = Factory.create(:partner)
      registrants << Factory.create(:maximal_registrant, :partner => other_partner)

      csv = FasterCSV.parse(partner.generate_registrants_csv)
      assert_equal 5, csv.length # including header
      assert_equal Registrant::CSV_HEADER, csv[0]
      assert_equal registrants[0].to_csv_array, csv[1]
      assert_equal registrants[1].to_csv_array, csv[2]
      assert_equal registrants[2].to_csv_array, csv[3]
      assert_equal registrants[3].to_csv_array, csv[4]
    end
  end

  describe "registration statistics" do
    describe "by state" do
      it "should tally registrants by state" do
        partner = Factory.create(:partner)
        3.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001")
        end
        2.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "94101")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = Factory.create(:partner)
        3.times do
          reg = Factory.create(:maximal_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001")
        end
        3.times do
          reg = Factory.create(:step_4_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "32001")
        end
        2.times do
          reg = Factory.create(:step_5_registrant, :partner => partner)
          reg.update_attributes(:home_zip_code => "94101")
        end
        stats = partner.registration_stats_state
        assert_equal 2, stats.length
        assert_equal "Florida", stats[0][:state_name]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "California", stats[1][:state_name]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end

    describe "by race" do
      it "should tally registrants by race" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "should treat race names in different languages as equivalent" do
        partner = Factory.create(:partner)
        4.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "SPANISH Hispanic", :locale => "es") }
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        1.times { Factory.create(:maximal_registrant, :partner => partner, :race => "SPANISH Multi-racial", :locale => "es") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 6, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 4, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "doesn't need both English and Spanish results" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "SPANISH Multi-racial", :locale => "es") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "when the race is blank it is called 'Unknown'" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "") }
        2.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Multi-racial") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Unknown", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end

      it "only uses completed/step_5 registrations for stats" do
        partner = Factory.create(:partner)
        3.times { Factory.create(:maximal_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:step_4_registrant, :partner => partner, :race => "Hispanic") }
        2.times { Factory.create(:step_5_registrant, :partner => partner, :race => "Multi-racial") }
        stats = partner.registration_stats_race
        assert_equal 2, stats.length
        assert_equal "Hispanic", stats[0][:race]
        assert_equal 3, stats[0][:registrations_count]
        assert_equal 0.6, stats[0][:registrations_percentage]
        assert_equal "Multi-racial", stats[1][:race]
        assert_equal 2, stats[1][:registrations_count]
        assert_equal 0.4, stats[1][:registrations_percentage]
      end
    end
  end
end
