require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DownloadsController do
  integrate_views

  describe "when PDF is ready" do
    before(:each) do
      @registrant = Factory.create(:step_5_registrant)
      stub(@registrant).merge_pdf { `touch #{@registrant.pdf_file_path}` }
      @registrant.generate_pdf
      @registrant.save!
    end

    it "provides a link to download the PDF" do
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "show"
      assert_select "span.button a[target=_blank]"
      assert_select "span.button a[onclick]"
    end

    after(:each) do
      `rm #{@registrant.pdf_file_path}`
    end
  end

  describe "when PDF is not ready" do
    before(:each) do
      @registrant = Factory.create(:step_5_registrant)
    end

    it "provides a link to download the PDF" do
      assert !@registrant.pdf_ready?
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_response :success
      assert_template "preparing"
    end

    it "times out preparing page after 30 seconds" do
      Registrant.update_all("updated_at = '#{35.seconds.ago.to_s(:db)}'", "id = #{@registrant.id}")
      assert !@registrant.pdf_ready?
      get :show, :registrant_id => @registrant.to_param
      assert_not_nil assigns[:registrant]
      assert_redirected_to registrant_finish_url(@registrant)
    end
  end

end
