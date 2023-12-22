# Load the rails application
require File.expand_path('../application', __FILE__)

require 'ext/string'
#longest length a string can be before it's truncated in index view
SHORTEN_LIMIT = 100

#Initialize the rails application
NZTrain::Application.initialize!
