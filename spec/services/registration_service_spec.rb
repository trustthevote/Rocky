require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrationService do

  describe 'create_record' do
    it 'should raise an error if the language is unknown' do
      lambda { RegistrationService.create_record(:lang => 'unknown') }.should raise_error RegistrationService::UnsupportedLanguage
    end

    it 'should raise validation errors when the record is invalid' do
      begin
        RegistrationService.create_record(:lang => 'en')
        fail 'ValidationError is expected'
      rescue RegistrationService::ValidationError => e
        e.field.should    == 'date_of_birth'
        e.message.should  == "can't be blank"
      end
    end

    context 'complete record' do
      before { @reg = mock(Registrant) }
      before { mock(Registrant).build_from_api_data({ :locale => nil }) { @reg } }

      it 'should save the record and generate PDF' do
        @reg.save { true }
        @reg.generate_pdf { true }
        RegistrationService.create_record({}).should
      end
    end
  end

end
