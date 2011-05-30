set :database, ENV['DATABASE_URL'] || 'sqlite://test.db'

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
end