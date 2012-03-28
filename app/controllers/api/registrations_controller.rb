class Api::RegistrationsController < ApplicationController

  # Creates the record and returns the URL to the PDF file or
  # the error message with optional invalid field name.
  def create
    pdf_path = RegistrationService.create_record(params_to_record(params)).pdf_path
    render :json => { :pdfurl => "http://#{request.host}#{pdf_path}" }
  rescue RegistrationService::ValidationError => e
    render :json => { :field_name => e.field, :message => e.message }, :status => 400
  rescue RegistrationService::UnsupportedLanguage => e
    render :json => { :message => e.message }, :status => 400
  end

  private

  # Converts the parameters into the record data
  def params_to_record(p)
    r = p.clone
    r.delete(:controller)
    r.delete(:action)
    r.delete(:format)
    r
  end

end
