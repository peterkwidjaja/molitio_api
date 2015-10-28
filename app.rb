require 'sinatra'
require 'rubygems'
require 'json'


get '/' do
  {
    'username'=> 'lol',
    'password'=> 'test'
  }.to_json
end

post '/auth' do
  username = params[:username]
  password = params[:password]
  {
    'secret_key'=>'1234512345'
  }.to_json
end

#REGISTER FROM MOBILE PHONE
get '/register' do
  {'message'=>'Successful'}.to_json
end

post '/register' do
  username = params[:username]
  password = params[:password]
  status 200
  {
    'message' => 'Successful'
  }.to_json
end


