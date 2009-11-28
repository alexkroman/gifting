require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-tags'

DataMapper::Logger.new(STDOUT, :debug)

DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db")

class Item
  include DataMapper::Resource
  validates_present :category_id, :asin, :title, :url, :price
  
  property :id,         Integer, :serial => true
  property :category_id, Integer
  property :asin,   String
  property :title,       String
  property :artist,       String
  property :author,       String
  property :url,   String, :index => true
  property :price,  String, :index => true
  
  has n, :surveys
end

class Survey
  include DataMapper::Resource
  
  validates_present :like
  property :id,         Integer, :serial => true
  property :like, Boolean
  property :created_at, DateTime
  belongs_to :item
  has_tags

  
end

DataMapper.auto_upgrade!