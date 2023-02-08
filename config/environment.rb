# Load the rails application
require File.expand_path('../application', __FILE__)

require 'rbconfig'

require 'ext/string'
#longest length a string can be before it's truncated in index view
SHORTEN_LIMIT = 100

#value between 0 and 1, used to reduce fraction of competitors shown on high-score table
HIGH_SCORE_LIMIT = 0.5

#ActiveRecord::Base.pluralize_table_names = false

require 'active_record/connection_adapters/postgresql_adapter'

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def set_standard_conforming_strings
    old, self.client_min_messages = client_min_messages, 'warning'
    execute('SET standard_conforming_strings = on', 'SCHEMA') rescue nil
  ensure
    self.client_min_messages = old
  end
end
#Initialize the rails application
NZTrain::Application.initialize!
