require 'rubygems'
require 'sinatra'
require 'erb'
require 'amazon/ecs'
require 'model'

enable :sessions

Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = "1QW4DWZG84P8WNG78R02"
  options[:aWS_secret_key] = "VdN92FTHaCefD/PA4dKnhVB2fEYpRadQDB+vCp3i"
end

def session_id
  env["rack.request.cookie_hash"]["rack.session"]
end

get '/' do
  @tags = Tag.all
  @surveys = Survey.all(:like => true, :order => [:id.desc], :limit => 30)
  erb :index
end

get '/give' do
  session[:type] = params[:type] if params[:type]
  session[:tags] = params[:tags] if params[:tags]
  @page = params[:page].to_i and @next_page = @page + 1
  
  asins = []
  session[:tags].split(",").each do |tag|
    @surveys = Survey.tagged_with(tag, :like => true)
    asins << @surveys.collect{|x| x.item.asin }
  end
  
  @item_list = Item.all(:asin => asins.first, :category_id => session[:type]).sort{rand}
  @item_list = @item_list + Item.all(:category_id => session[:type], :asin.not => asins).sort{rand}
    
  @item = @item_list[@page]

  redirect '/' unless @item

  @good_tags = []
  @item.surveys(:like => true).each do |survey|
    @good_tags << survey.tag_list
  end
  
  @bad_tags = []
  @item.surveys(:like => false).each do |survey|
    @bad_tags << survey.tag_list
  end
  
  
  erb :give
end

get '/vote' do
  if params[:page]
    @survey = Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => false)    
    redirect '/give?page=' + params[:page] 
  else
    @survey = Survey.create(:tag_list => session[:tags], :item => Item.first(:asin => params[:asin]), :like => true)    
    redirect params[:url]
  end
end

get '/tags/:tag' do
  @tag = params[:tag]
  @surveys = Survey.tagged_with(@tag, :like => true)
  erb :tag
end