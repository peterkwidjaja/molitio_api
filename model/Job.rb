require 'dm-core'
require 'dm-migrations'
require 'dm-aggregates'
require 'sinatra'

class Job
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required=>true
  property :description, Text
  property :start_date, String
  property :end_date, String
  property :reward, String
  property :contact, String
  property :creator_id, Integer, :required=>true
  property :creator_name, String, :required=>true
  property :applicant_id, Integer, :default=>-1
  property :finished, Boolean, :default=>false

end
