# file: partner.rake
# task: rake partner:add_whitelabel id app_css reg_css

namespace :partner do
  desc "Set a partner as whitelabeled and copy in asset files"
  task [:add_whitelabel, :partner_id, :app_css, :reg_css, :needs] => :environment do |t, args|
    if args.count != 3
      raise "Please specify all arguments: rake partner:add_whitelabel[partner_id,app_css_path,reg_css_path]"
    end
    begin
      output = Partner.add_whitelabel(args[:partner_id], args[:app_css], args[:reg_css])
    rescue Exception => e
      output = e.message
    end
    puts output
  end
end