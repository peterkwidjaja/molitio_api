require 'sinatra'
require 'rubygems'
require 'json'


get '/' do
  {
    'username'=> 'test',
    'password'=> 'pass1234'
  }.to_json
end

post '/auth' do
  username = params[:username]
  password = params[:password]
  if(username == "test" && password == "pass1234")
    {'auth_token'=>'1234512345'}.to_json
  else
    status 401
    {
      'message'=>'Wrong username and password combination'
    }.to_json
  end
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


