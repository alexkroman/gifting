require 'rubygems'
require 'sinatra'
require 'sinatra/sequel'
require 'erb'
require 'model'
require 'cgi'
require 'stringex'

get '/' do
  @products = Product.order(:sales_rank).all.group_by(&:category).sort_by{rand(srand)}[0..39]
  erb :index
end