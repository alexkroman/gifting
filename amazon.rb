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
  @item_list = Item.all(:asin => asins.first, :asin.not => session[:seen]).sort{|a,b| a.surveys.all(:like => true).size - a.surveys.all(:like => false).size <=> b.surveys.all(:like => true).size - b.surveys.all(:like => false).size}
  @item_list = @item_list + Item.all(:asin.not => asins, :asin.not => session[:seen]).sort{|a,b| a.surveys.all(:like => true).size - a.surveys.all(:like => false).size <=> b.surveys.all(:like => true).size - b.surveys.all(:like => false).size}
  @item = @item_list.first
  session[:seen] << @item.asin
  redirect '/' unless @item
  erb :give
end

get '/vote' do
  if params[:submit] == "i don't like this"
    Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => false)    
  elsif params[:submit] == 'i like this'
    Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => true)    
    redirect params[:url] if params[:url]
  end
  redirect '/give' 
end

get '/tags/:tag' do
  @tag = params[:tag]
  @surveys = Survey.tagged_with(@tag, :like => true, :unique => true)
  erb :tag
end