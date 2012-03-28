require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Api::RegistrationsController do

  describe 'create' do

    context 'success' do
      it 'should create a registration record' do
        path = '/1234567.pdf'
        mock(RegistrationService).create_record("data_field" => "1") { mock(Registrant).pdf_path { path } }
        post :create, :format => 'json', :data_field => "1"
        response.code.should == '200'
        response.body.should == { :pdfurl => "http://test.host#{path}" }.to_json
      end

      it 'should return a validation error' do
        mock(RegistrationService).create_record({}) { raise RegistrationService::ValidationError.new('invalid_field', 'Error message') }
        post :create, :format => 'json'
        response.code.should == '400'
        response.body.should == { :field_name => 'invalid_field', :message => 'Error message' }.to_json
      end

      it 'should return an unsupported language error' do
        mock(RegistrationService).create_record({}) { raise RegistrationService::UnsupportedLanguage }
        post :create, :format => 'json'
        response.code.should == '400'
        response.body.should == { :message => 'Unsupported language' }.to_json
      end
    end

  end

end
