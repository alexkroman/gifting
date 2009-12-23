require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-tags'
require 'open-uri'
require 'cgi'

DataMapper::Logger.new(STDOUT, :debug)

DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://root:@localhost/gifts") 

class Item
  include DataMapper::Resource
  attr_accessor :rank, :ups, :downs
  
  property :category_id, Integer
  property :asin,   String, :key => true
  property :title,       String, :length => 255
  property :artist,       String, :length => 255
  property :author,       String, :length => 255
  property :url,   String, :length => 255
  property :price,  String, :length => 255
  has n, :surveys
    
  def referral_url
    CGI.unescape(url).sub('=ws','=scriptfurnace-20')
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