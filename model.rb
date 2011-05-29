set :database, 'sqlite://test.db'

migration "create products" do
  database.create_table :products do
    primary_key :id
    string      :asin
    string      :title
    string      :small_image
    string      :medium_image
    string      :url
    string      :price
    string      :category
    string      :category_slug
    number      :sales_rank
  end
end

class Product < Sequel::Model
  
  def referral_url
    return '' unless url
    CGI.unescape(url).sub('=ws','=scriptfurnace-20').gsub('&','&amp;')
  end
  
  def rounded_price
    case price
      when 0..10
        10
      when 10..25
        25
      when 25..50
        50
      when 50..75
        75
      when 75..150
        150
      when 150..1000
        1000
    end
  end
  
end