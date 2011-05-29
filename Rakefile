require 'application'
require 'amazon/ecs'
require 'rake'
require 'fastercsv'

Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = "1QW4DWZG84P8WNG78R02"
  options[:aWS_secret_key] = "VdN92FTHaCefD/PA4dKnhVB2fEYpRadQDB+vCp3i"
end

task :keywords do
  Product.delete
  FasterCSV.foreach('keywords.csv', :headers => :first_row) {|row|
      search = row[0].gsub('best ','')
      res = Amazon::Ecs.item_search(search, {:response_group => 'Medium', :sort => 'salesrank'})
      res.items.each do |item|
        price = item.get('lowestnewprice/formattedprice')
        Product.insert(:title => item.get('itemattributes/title'),
                       :price => price,
                       :image => item.get('imageset/mediumimage/url'),
                       :url   => item.get('detailpageurl'),
                       :asin =>  item.get('asin'),
                       :category => item.get('browsenode/name'),
                       :category_id => node,
                       :sales_rank => item.get('salesrank'),
                       :category_slug => item.get('browsenode/name').to_url) if item
      end
  }
  
  
    
end

task :default do
  
@items = []
 
 all_categories = []
 
 categories = [
   171280,
   546272,
   3375251,
   229534,
   289962,
   1064954,
   11091801,
   5174,
   599858,
   3367581,
   764512,
   1055398,
   3760901,
   3370831,
   172282,
   139452,
   468642,
   301185,
   10963061,
   283155,
   3760911,
   540744,
   15684181,
   1036592,
   ]
    
   apparel = [1234356011,393526011,15743621,1046284,15743631,1046464,1046286,15743161,1046282,1266017011,2206546011,1234359011,1046466,15744111,15743761,2402554011,1040662,1040658,672123011,2227030011,1040660]
   baby = [617568011,2229211011,405369011,166736011,166835011,166764011,166777011,166828011,239226011,166856011,166887011,166804011,166863011,166842011]
   beauty = [11055991,11056591,11057131,11057241,11058281,11059581,11060281,11060451,11062741]
   books = [1,2,3,4,4366,5,6,86,301889,10,9,48,10777,17,13996,18,53,290060,20,173507,21,22,23,75,25,26,28,27]
   cell = [2237214011,16279191,2237215011,2237216011,2237217011,2237218011,10287631,2237219011,2237220011,2237221011,2237222011,16279141,2237223011,2237224011,2237225011,2237226011,1245558011,2237227011,2237228011,3519391,2237229011,3331091,13758051,2237230011]
   games = [291444011,471304,471280,2622269011,274445011,2242351011]
   dvd = [163296,538708,712256,517956,163313,163345,163357,466674,508532,163379,290738,578324,301667,163396,163414,586156,163420,508528,512030,163431,163448,467970,163450,163312]
   electronics = [281407,1065836,502394,1077068,541966,172526,667846011,11040111,172574,172623,16285901,1266092011]
   food = [16310311,16321991,16310231,16318751,16310251,16322431,16318981,2255571011,123382011,979861011,16320321,16322171,16310351,16322721,3594761]
   health = [10787321,3760941,15342811,3764441,3777891,3777371]
   garden = [1057792,3745171,1057794,284507,286168]
   improvement = [13397081,551240,13399391,552808,551238,3754081,551242,13749581,328182011,551236,119541011,1272941011]
   jewelry = [3888431,3885201,3885251,3885491,3885701,3880601,3885911,3890311,3898891,3887881,3886281,3893691,3887251,377110011,16014541]
   
   
   Product.delete
   
   (apparel + baby + beauty + books + cell + games + dvd + electronics + food + health + garden + improvement + jewelry).each do |node|
    Amazon::Ecs.send_request(:operation => 'BrowseNodeLookup', :response_group => 'TopSellers', :browse_node_id => node).doc.search('topitemset/topitem') do |item|
      begin
        
      Category.insert
      
      item = Amazon::Ecs.item_lookup(item.at('asin').inner_html, :response_group => 'Large').first_item         
      price = item.get('lowestnewprice/formattedprice')
      Product.insert(:title => item.get('itemattributes/title'),
                     :price => price,
                     :image => item.get('imageset/mediumimage/url'),
                     :url   => item.get('detailpageurl'),
                     :asin =>  item.get('asin'),
                     :category => item.get('browsenode/name'),
                     :category_id => node,
                     :sales_rank => item.get('salesrank'),
                     :category_slug => item.get('browsenode/name').to_url) if item
      rescue
      end
    
    end
  end

end

