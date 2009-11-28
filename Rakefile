require 'rake'
require 'fileutils'
require 'amazon'
require 'amazon/ecs'

Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = "1QW4DWZG84P8WNG78R02"
  options[:aWS_secret_key] = "VdN92FTHaCefD/PA4dKnhVB2fEYpRadQDB+vCp3i"
end

task :default => :import

desc "Import"
task :import do
  Item.all.destroy!
  @items = []
  categories = [
    283155,
    130,
    5174,
    468642,
    229534,
    1722821266092011,
    667846011,
    172630,
    1077068,
    361395011,
    284507,
    1057794,
    12890711,
    1036592,
    228013,
    3375251,
    3367581,
    3370831
    ]
    
    categories.each do |node|
     Amazon::Ecs.send_request(:operation => 'BrowseNodeLookup', :response_group => 'MostGifted', :browse_node_id => node).doc.search('topitemset/topitem') do |item|
       @items << {:asin => item.at('asin').inner_html, :category_id => node}        
     end
   end

   @items.each do |item|
     @item = Amazon::Ecs.item_lookup(item[:asin], :response_group => 'Medium').first_item
     Item.create!(:asin => @item.get('asin'), :category_id => item[:category_id], :title => @item.get('itemattributes/title'), :price => @item.get('itemattributes/listprice/formattedprice'), :url => @item.get('detailpageurl'), :author => @item.get('itemattributes/author'), :artist => @item.get('itemattributes/artist')) if @item
   end
  end
  
