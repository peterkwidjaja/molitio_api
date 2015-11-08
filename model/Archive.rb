require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'sinatra'

class Archive
  include DataMapper::Resource

  property :id,         Serial
  property :comment,    Text
  property :finish_date, String
  property :latitude,   Float
  property :longitude,  Float
  property :image, String
  property :job_id, Integer

end
