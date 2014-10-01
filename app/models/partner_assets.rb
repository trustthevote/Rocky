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
module PartnerAssets

  APP_CSS = "application.css"
  REG_CSS = "registration.css"
  PART_CSS = "partner.css"
  PDF_LOGO = "pdf_logo" #.jpeg, .jpg or .gif

  def css_present?
    application_css_present? && registration_css_present?
  end

  def any_css_present?
    application_css_present? || registration_css_present? || partner_css_present?
  end

  def application_css_present?
    File.exists?(self.absolute_application_css_path)
  end

  def registration_css_present?
    File.exists?(self.absolute_registration_css_path)
  end

  def partner_css_present?
    File.exists?(self.absolute_partner_css_path)
  end
  
  def pdf_logo_present?
    !pdf_logo_ext.nil?
  end
  
  def pdf_logo_ext
    logo_extensions = %w(gif jpg jpeg)
    logo_extensions.each do |ext|
      if File.exists?(self.absolute_pdf_logo_path(ext))
        return ext
      end
    end
    return nil
  end
    
  def pdf_logo_url(ext=nil)
    ext ||= pdf_logo_ext || "gif"
    "#{assets_url}/#{PDF_LOGO}.#{ext}"
  end

  def absolute_pdf_logo_path(ext=nil)
    ext ||= pdf_logo_ext || "gif"
    "#{assets_path}/#{PDF_LOGO}.#{ext}"
  end


  def assets_root
    if Rails.env.test?
      "#{Rails.root}/public/TEST"
    else
      "#{Rails.root}/public"
    end
  end

  def assets_url
    "//#{partner_assets_host}#{partner_path}"
  end
  
  def partner_assets_host
    if Rails.env.staging?
      "rtvstaging.osuosl.org"
    elsif Rails.env.staging2?
      "rtvstaging2.osuosl.org"
    elsif Rails.env.development? || Rails.env.test? || Rails.env.cucumber?
      "localhost:3000"
    else
      "register.rockthevote.com"
    end
  end

  def partner_path
    "/partners/#{self.id}"
  end

  def assets_path
    "#{assets_root}#{partner_path}"
  end

  def application_css_url
    "#{assets_url}/#{APP_CSS}"
  end
  def application_css_path
    "#{partner_path}/#{APP_CSS}"
  end

  def registration_css_url
    "#{assets_url}/#{REG_CSS}"
  end
  def registration_css_path
    "#{partner_path}/#{REG_CSS}"
  end

  def partner_css_url
    "#{assets_url}/#{PART_CSS}"
  end
  def partner_css_path
    "#{partner_path}/#{PART_CSS}"
  end

  def absolute_old_assets_path
    "#{assets_path}/old"
  end

  def absolute_application_css_path
    "#{assets_root}#{application_css_path}"
  end

  def absolute_registration_css_path
    "#{assets_root}#{registration_css_path}"
  end
  
  def absolute_partner_css_path
    "#{assets_root}#{partner_css_path}"
  end

end
