if !Rails.env.development? && !Rails.env.test? && (ENV['ROCKY_ROLE']=='PDFGEN' || ENV['ROCKY_ROLE']=='UTIL')
  WickedPdf.config = {
    :exe_path => '/var/www/register.rockthevote.com/rocky/shared/bundle/ruby/1.9.1/bin/wkhtmltopdf'
  }
end