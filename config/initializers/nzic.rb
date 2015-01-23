
Rails.configuration.to_prepare do
  NZIC::Base.class_eval do
    establish_connection "nzic_#{Rails.env}"
  end
end

