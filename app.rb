require 'sinatra'
require 'rubygems'
require 'json'


get '/' do
  {
    'username'=> 'test',
    'password'=> 'pass1234'
  }.to_json
end

#LOGIN FROM MOBILE PHONE
post '/auth' do
  username = params[:username]
  password = params[:password]
#  if(username == "test" && password == "pass1234")
#    {
#      'id'=>1,
#      'auth_token'=>'1234512345'
#    }.to_json
#  else
#    status 401
#    {
#      'message'=>'Wrong username and password combination'
#    }.to_json
#  end

{
  'id'=>1,
  'auth_token'=>'1234512345'
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

#GET AVAILABLE TASK
get '/tasks' do
  {
    'id'=> 1,
    'name'=>'Cleaning the toilet',
    'description'=>'One person needs to clean the toilet on level 3 until it is clean.',
    'start_date'=>'2015-12-20',
    'end_date'=>'2015-12-31'
  }.to_json
end

get '/:user/tasks' do
  //
end

get '/:user' do
  //
end

get '/meta' do
  {
    'last_update'=> '2015-10-29 01:10:55'
  }.to_json
end
