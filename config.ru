require 'rubygems'
require 'sinatra'
require 'amazon'

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application