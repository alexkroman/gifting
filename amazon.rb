require 'rubygems'
require 'sinatra'
require 'erb'
require 'amazon/ecs'

enable :sessions


Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = "1QW4DWZG84P8WNG78R02"
  options[:aWS_secret_key] = "VdN92FTHaCefD/PA4dKnhVB2fEYpRadQDB+vCp3i"
end

Amazon::Ecs.debug = true

get '/' do
  erb :index
end

post '/give' do
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
  
  @page = params[:page].to_i
  @next_page = @page + 1
  @items = []
  
  @authors.each_with_index do |book, i|
    result = Amazon::Ecs.item_search('', {:author => @authors[i], :sort => 'salesrank'})
    asin = result.items.first.get('asin')
    Amazon::Ecs.send_request({:operation => 'SimilarityLookup', :item_id => asin}).each do |item|
      next if item.get('itemattributes/author').to_s.downcase == result.items.first.get('author').to_s.downcase
      @items << {:author => item.get('itemattributes/author'), :title => item.get('itemattributes/title'), :url => item.get('detailpageurl')}
    end
  end

  @movies.each_with_index do |movie, i|
    result = Amazon::Ecs.item_search('', {:title => @movies[i], :search_index => 'DVD', :sort => 'salesrank'})
    asin = result.items.first.get('asin')
    
    Amazon::Ecs.send_request({:operation => 'SimilarityLookup', :item_id => asin}).items.each do |item|   
      @items << {:title => item.get('itemattributes/title'), :url => item.get('detailpageurl')}
    end
  end

  @bands.each_with_index do |band, i|
    result = Amazon::Ecs.item_search('', {:artist => @bands[i], :search_index => 'Music', :sort => 'salesrank'})
    asin = result.items.first.get('asin')
    Amazon::Ecs.send_request({:operation => 'SimilarityLookup', :item_id => asin}).items.each do |item|
      next if item.get('itemattributes/artist').to_s.downcase == result.items.first.get('artist').to_s.downcase
      @items << {:title => item.get('itemattributes/title'), :url => item.get('detailpageurl'), :artist => item.get('itemattributes/artist')}[0..5]
    end
  end

  @electronics.each_with_index do |brand, i|
    result = Amazon::Ecs.item_search('', {:brand => @electronics[i], :search_index => 'Electronics', :sort => 'salesrank'}).items.each do |item|
      @items << {:title => item.get('itemattributes/title'), :url => item.get('detailpageurl')}
    end
    result = Amazon::Ecs.item_search('', {:brand => @electronics[i], :search_index => 'PC Hardware', :sort => 'salesrank'}).items.each do |item|
      @items << {:title => item.get('itemattributes/title'), :url => item.get('detailpageurl')}
    end
  end
  
  @apparel.each_with_index do |brand, i|
    result = Amazon::Ecs.item_search('', {:brand => @apparel[i], :search_index => 'Apparel', :sort => 'salesrank'}).items.each do |item|
       @items << {:title => item.get('itemattributes/title'), :url => item.get('detailpageurl')}
     end
  end 
      
  @item = @items.sort{rand}[@page]
  erb :give
end