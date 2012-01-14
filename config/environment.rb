# Load the rails application
require File.expand_path('../application', __FILE__)

require 'rbconfig'

require 'ext/string'
#longest length a string can be before it's truncated in index view
SHORTEN_LIMIT = 100

#value between 0 and 1, used to reduce fraction of competitors shown on high-score table
HIGH_SCORE_LIMIT = 0.5

Rails.env='development'

#Initialize the rails application
NztrainV2::Application.initialize!
