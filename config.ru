require 'rubygems'
require 'sinatra'
require 'amazon'

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

run Sinatra::Application