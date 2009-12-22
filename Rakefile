require 'application'
require 'fileutils'
require 'amazon/ecs'

Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = "1QW4DWZG84P8WNG78R02"
  options[:aWS_secret_key] = "VdN92FTHaCefD/PA4dKnhVB2fEYpRadQDB+vCp3i"
end

task :default => :import

desc "Import"
task :import do
  @items = []
   
  categories = [
    599858,
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
    3370831,
    1064954,
    172635,
    172456,
    193870011,
    565098,
    565108,
    502394,
    301185,
    11091801,
    1057792,
    510080,
    228013,
    286168,
    12923371,
    16310101,
    51537011,
    3370831,
    3760901,
    3760911,
    165793011,
    672123011,
    377110011,
    3407731,
    706814011,
    2206626011,
    706809011,
    2232464011,
    3410851,
    3386071,
    328182011,
    228013,
    3754161,
    495224,
    551242,
    15684181,
    346333011
    ]
    p 'Starting...'
    categories.each do |node|
     Amazon::Ecs.send_request(:operation => 'BrowseNodeLookup', :response_group => 'MostGifted', :browse_node_id => node).doc.search('topitemset/topitem') do |item|
       @items << {:asin => item.at('asin').inner_html, :category_id => node}        
     end
     Amazon::Ecs.send_request(:operation => 'BrowseNodeLookup', :response_group => 'MostWishedFor', :browse_node_id => node).doc.search('topitemset/topitem') do |item|
       @items << {:asin => item.at('asin').inner_html, :category_id => node}        
     end
   end

   @items.each do |item|
     @item = Amazon::Ecs.item_lookup(item[:asin], :response_group => 'Medium').first_item
     if @item
       @duplicate = Item.get(@item.get('asin'))
       if @duplicate
         @duplicate.attributes = {:title => @item.get('itemattributes/title'), :price => @item.get('itemattributes/listprice/formattedprice'), :url => @item.get('detailpageurl')}
         @duplicate.save!
       else
         Item.create!(:asin => @item.get('asin'), :category_id => item[:category_id], :title => @item.get('itemattributes/title'), :price => @item.get('itemattributes/listprice/formattedprice'), :url => @item.get('detailpageurl'), :author => @item.get('itemattributes/author'), :artist => @item.get('itemattributes/artist'))
       end
    end
   end
  end
  
