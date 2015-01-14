require 'geocoder/results/base'
 
module MockGeocoderSpecHelper
  def self.included(base)
    base.before :each do
      allow(::Geocoder).to receive(:search).and_raise(
        RuntimeError.new 'Use "mock_geocoding!" method in your tests.')
    end
    base.before :each do
      mock_geocoding!
    end
  end
 
  def mock_geocoding!(options = {})
    options.reverse_merge!(
      address: 'Address',
      coordinates: [1, 2],
      state: 'State',
      state_code: 'State Code',
      country: 'Australia',
      country_code: 'AU'
    )
 
    MockResult.new.tap do |result|
      options.each do |prop, val|
        allow(result).to receive(prop).and_return(val)
      end
      allow(Geocoder).to receive(:search).and_return([result])
    end
  end
 
  class MockResult < ::Geocoder::Result::Base
    def initialize(data = [])
      super(data)
    end
  end
end

