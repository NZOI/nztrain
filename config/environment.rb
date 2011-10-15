# Load the rails application
require File.expand_path('../application', __FILE__)

require 'ext/string'
SHORTEN_LIMIT = 10000

# Initialize the rails application
NztrainV2::Application.initialize!
