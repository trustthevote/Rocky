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
class RegistrationService

  # Validation error
  class ValidationError < StandardError
    attr_reader :field

    def initialize(field, message)
      super(message)
      @field = field
    end
  end

  # Creates a record and returns it.
  def self.create_record(data)
    attrs = data_to_attrs(data)
    reg = Registrant.build_from_api_data(attrs)

    if reg.save
      reg.generate_pdf
    else
      validate_language(reg)
      raise_validation_error(reg)
    end

    reg
  end

  private

  def self.validate_language(reg)
    raise UnsupportedLanguageError if reg.errors.on(:locale)
  end

  def self.raise_validation_error(reg)
    error = reg.errors.sort.first
    raise ValidationError.new(error.first, error.last)
  end

  def self.data_to_attrs(data)
    attrs = data.clone
    attrs[:locale] = attrs.delete(:lang)
    attrs
  end

end
