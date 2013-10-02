CarrierWave.configure do |config|
  config.storage = :file
  config.root = Rails.root.join('db/data').to_s
end
