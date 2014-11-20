unless Rails.env.development? || Rails.env.test? || ENV['NO_PDFS']
  WickedPdf.config = {
    :exe_path => '/var/www/register.rockthevote.com/rocky/shared/bundle/ruby/1.9.1/bin/wkhtmltopdf'
  }
end