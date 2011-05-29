require 'rubygems'
require 'sinatra'
require 'sinatra/sequel'
require 'erb'
require 'model'
require 'cgi'
require 'stringex'

get '/' do
  @products = Product.order(:category).limit(200).all.group_by(&:category)
  erb :index
end

get '/:search' do
  @products = Product.filter(:category_slug => params[:search]).order(:sales_rank)
  @go_to_product = true
  erb :show
end