require 'application'
require 'amazon/ecs'
require 'rake'
require 'fastercsv'

Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = "1QW4DWZG84P8WNG78R02"
  options[:aWS_secret_key] = "VdN92FTHaCefD/PA4dKnhVB2fEYpRadQDB+vCp3i"
  options[:AssociateTag] = 'scriptfurnace-20'
end

task :keywords do
  Product.delete
  FasterCSV.foreach('keywords.csv', :headers => :first_row) {|row|
      minimum_price = (row[2].nil? ? 15 : row[2]).to_i * 100  
      search_index = row[1]
      default_sort = (search_index =~ /Apparel|Books|DVD|Grocery|MP3Downloads|Shoes|SportingGoods|Watches/) ? 'relevancerank' : 'pmrank'
      sort = row[3].nil? ? default_sort : row[3]
      search = row[0].gsub('best ','')        
      p "keyword: #{search} | price: #{minimum_price} | index: #{search_index} | sort: #{sort} | node: #{row[4]}"
      res = Amazon::Ecs.item_search(search, {:browse_node => row[4], :response_group => 'Medium', :search_index => search_index, :minimum_price => minimum_price, :sort => sort})
      res.items.each do |item|
        small_image = item.get('imageset/smallimage/url')
        price = item.get('lowestnewprice/formattedprice')
        title = item.get('itemattributes/title')
        p "#{title} / #{price}"
        sales_rank = item.get('salesrank').to_i
        Product.insert(:title => title,
                       :price => price,
                       :small_image => small_image,
                       :medium_image => item.get('imageset/mediumimage/url'),
                       :url   => item.get('detailpageurl'),
                       :asin =>  item.get('asin'),
                       :category => search,
                       :category_slug => search.to_url,
                       :sales_rank => sales_rank) if price and small_image
      end
  } 
end
