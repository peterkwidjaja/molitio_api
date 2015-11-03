require 'dm-core'
require 'dm-aggregates'
require 'sinatra'
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/database.db")
end
configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end
