require 'rubygems'
require 'sinatra'
require 'erb'
require 'amazon/ecs'
require 'model'


enable :sessions
#set :logging, true


Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = "1QW4DWZG84P8WNG78R02"
  options[:aWS_secret_key] = "VdN92FTHaCefD/PA4dKnhVB2fEYpRadQDB+vCp3i"
end

Amazon::Ecs.debug = true

def session_id
  env["rack.request.cookie_hash"]["rack.session"]
end

get '/' do
  @surveys = Survey.all(:like => true, :order => [:created_at.desc])
  erb :index
end

get '/give' do
  session[:type] = params[:type] if params[:type]
  if params[:tags]
    session[:tags] = params[:tags]
    params[:tags].split(",").each do |tag|
      #raise tag.inspect
      Tag.create(:name => tag) unless Tag.get(tag)
    end
  end
  @page = params[:page].to_i
  @next_page = @page + 1
  
  asins = []
  @item_list = nil
  session[:tags].split(",").each do |tag|
    @surveys = Survey.all(:tags.like => "%#{tag}%", :like => true)
    asins << @surveys.collect{|x| x.item.asin }
  end
  

  @item_list = Item.all(:asin => asins.first)
  @item_list = @item_list + Item.all(:category_id => session[:type]).sort{rand}
  @item = @item_list[@page]
  
  if Item.all(:category_id => session[:type]).size == @page + 1 
    @all_done = true
  else
    @all_done = false
  end
  erb :give
end

get '/vote' do
  if params[:page]
    @survey = Survey.new(:session_id => session_id, :tags => session[:tags], :item => Item.first(:asin => params[:asin]), :like => false)
    @survey.save!
    redirect '/give?page=' + params[:page] 
  else
    @survey = Survey.new(:session_id => session_id, :tags => session[:tags], :item => Item.first(:asin => params[:asin]), :like => true)
    @survey.save!
    redirect params[:url]
  end
end

get '/tags/:tag' do
  @tag = params[:tag]
  @surveys = Survey.all(:tags.like => "%#{params[:tag]}%", :like => true)
  erb :tag
end