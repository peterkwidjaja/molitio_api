require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'sinatra'

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String, :required=>true
  property :password, String, :required=>true
  property :auth_token, String
end
DataMapper.finalize
