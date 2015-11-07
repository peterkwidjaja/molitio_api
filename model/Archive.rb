require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'sinatra'

class Archive
  include DataMapper::Resource

  belongs_to :job

  property :id,         Serial
  property :comment,    Text
  property :blob,       Blob
  property :finish_date, String
  property :latitude,   Float
  property :longitude,  Float

end
