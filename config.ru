require 'rubygems'
require 'sinatra'
require 'hotels'
require 'rack/cache'

use Rack::Cache,
  :verbose => true,
  :metastore   => 'file:cache/meta',
  :entitystore => 'file:cache/body'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => ENV['RACK_ENV']
)

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application