require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-tags'

DataMapper::Logger.new(STDOUT, :debug)

DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db")

class Item
  include DataMapper::Resource
  validates_present :category_id, :asin, :title, :url, :price
  property :category_id, Integer
  property :asin,   String, :key => true
  property :title,       String
  property :artist,       String
  property :author,       String
  property :url,   String
  property :price,  String
  has n, :surveys
end

class Survey
  include DataMapper::Resource
  validates_present :like
  property :id,         Integer, :serial => true
  property :like, Boolean, :index => true
  property :created_at, DateTime
  belongs_to :item
  has_tags  
end

DataMapper.auto_upgrade!