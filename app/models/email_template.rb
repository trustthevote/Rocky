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
class EmailTemplate < ActiveRecord::Base

  TEMPLATE_NAMES = %w(confirmation reminder chaser thank_you_external).inject([]){|result,t| result + I18n.available_locales.collect{|l| ["#{t}.#{l}", "#{t.capitalize.gsub("_", " ")} #{l.upcase}"]} }
  
  
  # [ [ 'confirmation.en', 'Confirmation EN' ], [ 'confirmation.es', 'Confirmation ES' ],
  #      [ 'reminder.en', 'Reminder EN' ], [ 'reminder.es', 'Reminder ES' ] ]

  belongs_to :partner

  validates_presence_of   :partner
  validates_presence_of   :name
  validates_uniqueness_of :name, :scope => :partner_id

  # Sets the template body (creates or updates as necessary)
  def self.set(partner, name, body)
    return unless partner
    tmpl = EmailTemplate.find_or_initialize_by_partner_id_and_name(partner.id, name)
    tmpl.body = body
    tmpl.save!
  end
  def self.set_subject(partner, name, subject)
    return unless partner
    tmpl = EmailTemplate.find_or_initialize_by_partner_id_and_name(partner.id, name)
    tmpl.subject = subject
    tmpl.save!    
  end

  # Returns the template body
  def self.get(partner, name)
    return nil unless partner
    EmailTemplate.find_by_partner_id_and_name(partner.id, name).try(:body)
  end
  def self.get_subject(partner, name)
    return nil unless partner
    EmailTemplate.find_by_partner_id_and_name(partner.id, name).try(:subject)
  end

  # Returns TRUE if the partner email template with this name is non-empty
  def self.present?(partner, name)
    get(partner, name).present?
  end

end
