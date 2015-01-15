class EstimateUserCountries < ActiveRecord::Migration
  def up
    User.find_each do |u|
      ip = u.current_sign_in_ip || u.last_sign_in_ip
      if u.country_code.nil? && ip
        u.country_code = Geocoder.search(ip).first.try(:country_code)
        u.save
      end
    end
  end
  def down
  end
end
