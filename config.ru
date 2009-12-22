require 'rubygems'
require 'sinatra'
require 'application'

log = File.new("log/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

Sinatra::Application.default_options.merge!(
  :run => false,
  :environment => :production
)

run Sinatra::Application