require 'rubygems'
require 'sinatra'
require 'erb'
require 'amazon/ecs'
require 'model'

enable :sessions

def cache_control
  headers['Cache-Control'] = 'max-age=900, public'
end

get '/' do
  @tags = repository(:default).adapter.query("SELECT tags.*, COUNT(tags.id) AS tags_count FROM tags
  INNER JOIN taggings ON tags.id = taggings.tag_id
  INNER JOIN surveys ON taggings.taggable_id = surveys.id
  WHERE surveys.like = 't'
  GROUP BY tags.id ORDER BY tags_count DESC LIMIT 15")
  @surveys = Survey.all(:like => true, :order => [:id.desc], :limit => 20)
  erb :index
end

def do_tags
  if params[:tags]
    session[:tags] = params[:tags] 
    session[:seen] = ['xxx']
  end
end

get '/search' do
  do_tags
  asins = []
  session[:tags].split(",").each do |tag|
    @surveys = Survey.tagged_with(tag, :like => true)
    asins << @surveys.collect{|x| x.item.asin }
  end
  @item_list = Item.all(:asin => asins.first, :asin.not => session[:seen]).sort{|a,b| a.surveys.all(:like => true).size <=> b.surveys.all(:like => true).size}.reverse
  @item_list = @item_list + Item.all(:asin.not => asins, :asin.not => session[:seen]).sort{|a,b| a.surveys.all(:like => true).size <=> b.surveys.all(:like => true).size}.reverse
  @item = @item_list.first
  session[:remaining] = @item_list.size
  redirect '/give/' + @item.asin
end

get '/give/:asin' do
  do_tags
  @remaining = session[:remaining]
  @item = Item.get(params[:asin])  
  session[:seen] << @item.asin
  redirect '/' unless @item
  erb :give
end

get '/vote' do
  if params[:submit] == "i don't want to get this"
    Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => false)    
  elsif params[:submit] == 'i might get this'
    Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => true)    
    redirect params[:url] if params[:url]
  end
  redirect '/search' 
end