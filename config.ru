require 'rubygems'
require 'sinatra'
require 'amazon'

use Rack::Cache,
  :verbose => true,
  :metastore   => 'file:cache/meta',
  :entitystore => 'file:cache/body'

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application