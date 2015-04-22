# encoding: utf-8

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'minitest/mock'
require "mocha/setup"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

#ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
#
#silence_stream(STDOUT) do
#  ActiveRecord::Migrator.migrate File.expand_path('../../db/migrate/', __FILE__)
#end

#def drop_all_tables
#  ActiveRecord::Base.connection.tables.each do |table|
#    ActiveRecord::Base.connection.drop_table(table)
#  end
#end
