require 'rubygems'
require 'bundler'

Bundler.require

require 'rack/cache'
require './rumour'

use Rack::Cache, :metastore => 'heap:/', :entitystore => 'heap:/'
run Sinatra::Application
