require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-tags'
require 'open-uri'
require 'cgi'

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
  
  def referral_url
    CGI.unescape(url).sub('=ws','=scriptfurnace-20')
  end
  
  def score
    surveys(:like => true).size - (surveys(:like => false).size * 0.25)
  end
  
  def skips
    surveys(:like => false).size
  end

end

class Survey
  include DataMapper::Resource
  validates_present :like
  property :id,         Serial
  property :like, Boolean, :index => true
  property :created_at, DateTime
  belongs_to :item
  has_tags  
end

DataMapper.auto_upgrade!