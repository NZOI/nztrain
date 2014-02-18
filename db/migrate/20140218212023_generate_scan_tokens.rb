class GenerateScanTokens < ActiveRecord::Migration
  def up
    Item.find_each do |item|
      if item[:scan_token].nil?
        item.scan_token = SecureRandom.random_number(100000000)
        item.save
      end
    end
  end
  def down
  end
end
