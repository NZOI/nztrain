# Load the rails application
require File.expand_path('../application', __FILE__)

require 'ext/string'
SHORTEN_LIMIT = 100

HIGH_SCORE_LIMIT = 0.5
# Initialize the rails application
NztrainV2::Application.initialize!
