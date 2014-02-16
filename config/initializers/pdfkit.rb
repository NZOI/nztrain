
PDFKit.configure do |config|
  config.wkhtmltopdf = File.expand_path('bin/wkhtmltopdf', Rails.root)
end
