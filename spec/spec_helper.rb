$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV["RACK_ENV"] ||= 'development'
require File.expand_path("../../config/environment", __FILE__)

require 'grape'

require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'json'
require 'rack/test'
require 'base64'
require 'json'
require 'mime/types'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f}

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.raise_errors_for_deprecations!
end
