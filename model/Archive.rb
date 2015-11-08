require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'sinatra'

class Archive
  include DataMapper::Resource

  property :id,         Serial
  property :comment,    Text
  property :finish_date, String
  property :latitude,   Decimal
  property :longitude,  Decimal
  property :image, String
  property :job_id, Integer

end
