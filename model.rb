set :database, "sqlite://database.db"

migration "create products" do
  database.create_table :products do
    primary_key :id
    String      :asin
    String      :title
    String      :small_image
    String      :medium_image
    String      :url
    String      :price
    String      :category
    String      :category_slug
    Numeric     :sales_rank
    index       :category
    index       :category_slug
  end
end

class Product < Sequel::Model
end