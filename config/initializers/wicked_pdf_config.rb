if !Rails.env.development? && !Rails.env.test? && (ENV['ROCKY_ROLE'].to_s.downcase=='pdfgen' || ENV['ROCKY_ROLE'].to_s.downcase=='util')
  WickedPdf.config = {
    :exe_path => '/var/www/register.rockthevote.com/rocky/shared/bundle/ruby/1.9.1/bin/wkhtmltopdf'
  }
end