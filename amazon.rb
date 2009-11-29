require 'rubygems'
require 'sinatra'
require 'erb'
require 'amazon/ecs'
require 'model'

enable :sessions

get '/' do
  @tags = Tag.all
  @surveys = Survey.all(:like => true, :order => [:id.desc], :limit => 30)
  erb :index
end

get '/give' do
  if params[:tags]
    session[:tags] = params[:tags] 
    session[:seen] = ['xxx']
  end
  @page = params[:page].to_i and @next_page = @page + 1
  
  asins = []
  session[:tags].split(",").each do |tag|
    @surveys = Survey.tagged_with(tag, :like => true)
    asins << @surveys.collect{|x| x.item.asin }
  end
  @item_list = Item.all(:asin => asins.first, :asin.not => session[:seen]).sort{rand <=> rand}
  @item_list = @item_list + Item.all(:asin.not => asins, :asin.not => session[:seen]).sort{rand <=> rand}
  @item = @item_list.first
  session[:seen] << @item.asin
  redirect '/' unless @item
  erb :give
end

get '/vote' do
  if params[:like]
    Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => false)    
    redirect '/give' 
  else
    Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => true)    
    redirect params[:url]
  end
end

get '/tags/:tag' do
  @tag = params[:tag]
  @surveys = Survey.tagged_with(@tag, :like => true, :unique => true)
  erb :tag
end