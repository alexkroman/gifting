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

Amazon::Ecs.debug = true

get '/' do
  erb :index
end

post '/calculate' do
  Item.all(:session_id.eql => session_id).destroy!
  @authors = []
  @movies = []
  @bands = []
  @electronics = []
  @household = []
  @apparel = []
  @authors = params[:author].delete_if{|x| x.empty?} if params[:author]
  @movies = params[:movie].delete_if{|x| x.empty?} if params[:movie] 
  @bands = params[:band].delete_if{|x| x.empty?} if params[:band]
  @electronics = params[:electronic].delete_if{|x| x.empty?} if params[:electronic]
  @apparel = params[:apparel].delete_if{|x| x.empty?} if params[:apparel]
  @household = params[:household].delete_if{|x| x.empty?} if params[:household]
  

  @items = []
  asins = []
  
  @authors.each_with_index do |book, i|
    author = Amazon::Ecs.item_search('', {:author => @authors[i], :sort => 'salesrank'})
    asins << author.items.first.get('asin')
  end

  @movies.each_with_index do |movie, i|
    result = Amazon::Ecs.item_search('', {:title => @movies[i], :search_index => 'DVD', :sort => 'salesrank'})
    asins << result.items.first.get('asin')
  end

  @bands.each_with_index do |band, i|
    result = Amazon::Ecs.item_search('', {:artist => @bands[i], :search_index => 'Music', :sort => 'salesrank'})
    asins << result.items.first.get('asin')
  end
  
  Amazon::Ecs.send_request({:operation => 'SimilarityLookup', :item_id => asins.join(','), :similarity_type => 'Random'}).items.each do |item|
    @items << {:asin => item.get('asin')}
  end

  @types = params[:type] || []
  
  @types.each do |node|
    Amazon::Ecs.send_request(:operation => 'BrowseNodeLookup', :response_group => 'MostGifted', :browse_node_id => node).doc.search('topitemset/topitem') do |item|
      @items << {:asin => item.at('asin').inner_html}        
    end
  end
    
  @items.sort{rand <=> rand}
  
  @items.each do |item|
    @item = Amazon::Ecs.item_lookup(item[:asin], :response_group => 'Medium').first_item
    Item.create!(:session_id => session_id, :title => @item.get('itemattributes/title'), :price => @item.get('itemattributes/listprice/formattedprice'), :url => @item.get('detailpageurl'), :author => @item.get('itemattributes/author'), :artist => @item.get('itemattributes/artist'), :asin => item['asin']) if @item
  end

  redirect '/give'
end

def env
  env = Rack::Request.new(env)
end
  
def session_id
  env['rack.request.cookie_hash']["rack.session"]
end

get '/give' do
  @page = params[:page].to_i
  #raise @page.inspect
  @next_page = @page + 1
  @items = Item.all(:session_id.eql => session_id, :limit => 1, :offset => @page)
  if Item.all(:session_id.eql => session_id).size == @page + 1 
    @all_done = true
  else
    @all_done = false
  end
  @item = @items.first
  erb :give
end
