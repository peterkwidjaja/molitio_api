require 'sinatra'
require 'rubygems'
require 'json'
require 'securerandom'
require './config/environments'
require './model/User.rb'
require './model/Job.rb'
DataMapper.finalize

get '/' do
  {
    'username'=> 'test',
    'password'=> 'pass1234'
  }.to_json
end

#LOGIN FROM MOBILE PHONE
post '/auth' do
  username = params[:username].to_s
  password = params[:password].to_s
  verify = User.first(:username=>username)
  if (!verify)
    status 401
  elsif verify.password == password
    status 200
    {
      'id'=>verify.id.to_i,
      'auth_token'=>verify.auth_token
    }.to_json
  end
end

#REGISTER FROM MOBILE PHONE
get '/register' do
  if true
    token = SecureRandom.urlsafe_base64
    User.create(:username=>username, :password=>password, :auth_token=>token)
    {
      'message'=>'Successful',
      'token'  => token
    }.to_json
  else
    status 401
  end
end

post '/register' do
  username = params[:username]
  password = params[:password]
  verify = User.count(:username=>username)
  if verify==0
    token = SecureRandom.urlsafe_base64
    User.create(:username=>username, :password=>password, :auth_token=>token)
    {
      'message'=>'Successful',
      'token'  => token
    }.to_json
  else
    status 401
  end
end

#GET AVAILABLE TASK
get '/jobs' do
  {[
    {
      'id'=> 1,
      'title'=>'Cleaning the toilet',
      'description'=>'One person needs to clean the toilet on level 3 until it is clean.',
      'start_date'=>'2015-12-20',
      'end_date'=>'2015-12-31',
      'status' => 'Unassigned',
      'reward'=>'$5000',
      'contact'=>'12345678',
      'creator_id'=>1,
      'creator_name'=> 'Bob'
    },
    {
      'id'=>2,
      'title'=>'TEST 2',
      'description' => 'HELLOOOOOOOO',
      'start_date'=>'2015-11-03',
      'end_date'=>'2016-01-01',
      'status' => 'Unassigned',
      'reward'=>'$5000',
      'contact'=>'12345678',
      'creator_id'=>1,
      'creator_name'=> 'Bob'
    }
  ]}.to_json
end

get '/:user/jobs' do
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
