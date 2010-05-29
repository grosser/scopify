require 'rubygems'

$LOAD_PATH << "#{File.dirname(__FILE__)}/.."
require 'scopify'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new
MongoMapper.database = 'scopify_examples'

MongoMapper::Document::ClassMethods.send(:include, Scopify::ClassMethods)
MongoMapper::Plugins::Associations::Proxy.send(:include, Scopify::ClassMethods)

class User
  include MongoMapper::Document

  scope :xxx, :limit => 1

  many :posts
end

class Post
  include MongoMapper::Document
  key :user_id, ObjectId
  key :title, String
end

puts User.xxx.scoped(:order => 'xxx').to_hash.inspect
puts "(should be {:limit=>1, :order=>'xxx'})"

puts User.create.posts.loaded?
User.create.posts.scoped(:limit => 1).all