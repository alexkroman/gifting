require 'rubygems'
require 'sinatra'
require 'erb'
require 'amazon/ecs'
require 'model'

enable :sessions

get '/' do
  cache_for 60 * 5
  @tags = repository(:default).adapter.query("SELECT tags.name, COUNT(tags.id) AS tags_count FROM tags
  INNER JOIN taggings ON tags.id = taggings.tag_id
  INNER JOIN surveys ON taggings.taggable_id = surveys.id
  WHERE surveys.like = 't'
  GROUP BY tags.id, tags.name ORDER BY tags_count DESC LIMIT 30")
  @surveys = Survey.all(:like => true, :order => [:id.desc], :limit => 20)
  erb :index
end

def start_over
  if params[:so]
    session[:seen] = ['xxx']    
  end
end

def sort_by_random(collection)
    collection.sort{|a,b| rand(srand) <=> rand(srand) }
end

get '/search' do
  start_over
  good_asins = []
  bad_asins = []
  params[:tags].split(",").each do |tag|
    if Tag.first(:name => tag)
      @surveys = Survey.tagged_with(tag, :like => true) 
      good_asins |= @surveys.collect{|x| x.item.asin }
      @surveys = Survey.tagged_with(tag, :like => false) 
      bad_asins |= @surveys.collect{|x| x.item.asin }
    end
  end
  
  @item_list = Item.all(:asin.not => session[:seen])
    @item_list.each do |item|
      distance_in_hours = (((Time.now - Time.local(2009,12,1)).abs)/3600).floor
      item.ups = item.surveys(:like => true).size
      item.downs = item.surveys(:like => false).size
      points = item.ups - (item.downs * 0.25)
      points += 5 if good_asins.include?(item.id)
      points -= 5 if bad_asins.include?(item.id)
      item.rank = points
    end
  @item_list.sort!{|x,y| y.rank <=> x.rank }
  @item = @item_list.uniq.first
  redirect '/' unless @item
  redirect '/give/' + @item.asin + '?tags=' + params[:tags]
end

get '/give/:asin' do
  start_over
  @item = Item.first(:asin => params[:asin]) 
  session[:seen] << @item.asin
  erb :give
end

get '/vote' do
  if params[:submit] == "No"
    create_survey(false)
  else
    create_survey(true)
  end
  redirect '/search?tags=' + params[:tags] 
end

def create_survey(like)
  Survey.create(:tag_list => params[:tags], :item => Item.first(:asin => params[:asin]), :like => like)    
end

def cache_for(time)
  response['Cache-Control'] = "public, max-age=#{time.to_i}"
end
