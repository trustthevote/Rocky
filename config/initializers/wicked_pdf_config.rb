if !Rails.env.development? && !Rails.env.test? && (ENV['ROCKY_ROLE'].downcase=='pdfgen' || ENV['ROCKY_ROLE'].downcase=='util')
  WickedPdf.config = {
    :exe_path => '/var/www/register.rockthevote.com/rocky/shared/bundle/ruby/1.9.1/bin/wkhtmltopdf'
  }
end