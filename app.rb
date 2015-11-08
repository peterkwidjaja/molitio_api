require 'sinatra'
require 'rubygems'
require 'json'
require 'securerandom'
require 'dm-core'
require 'dm-migrations'
require './config/environments'
require './model/User.rb'
require './model/Archive.rb'
require './model/Job.rb'

DataMapper.finalize
DataMapper.auto_migrate!

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
post '/register' do
  username = params[:username]
  password = params[:password]
  name = params[:name]
  verify = User.count(:username=>username)
  if verify==0
    token = SecureRandom.urlsafe_base64
    User.create(:username=>username, :password=>password, :name=>name,:auth_token=>token)
    {
      'id' => User.first(:username=>username).id,
      'auth_token'  => token
    }.to_json
  else
    status 401
  end
end

#GET all tasks meta
get '/joblist' do
  content_type :json
  output = Array.new
  results = Job.all(:applicant_id=>-1)
  results.each do |job|
    obj = {
      'id'=>job.id,
      'title'=>job.title.to_s,
      'start_date'=>job.start_date.to_s,
      'end_date'=>job.end_date.to_s
    }
    output.push(obj)
  end
  output.to_json
end

#GET task details of an id
get '/jobs/:id' do
  jobId = params['id']
  result = Job.first(:id=>jobId)
  if(result)
    {
      'id'=>result.id,
      'title'=>result.title,
      'description'=>result.description,
      'start_date'=>result.start_date,
      'end_date'=>result.end_date,
      'reward'=>result.reward,
      'contact'=>result.contact,
      'creator_id'=>result.creator_id,
      'creator_name'=>result.creator_name
    }.to_json
  else
    status 404
  end
end

post '/jobs' do
  id = params[:user_id]
  auth_token = params[:auth_token]
  verify = User.first(:id=>id)
  if(verify && verify.auth_token == auth_token)
    job=Job.create(
      :title=>params[:title],
      :description=>params[:description],
      :start_date=>params[:start_date],
      :end_date=>params[:end_date],
      :reward=>params[:reward],
      :contact=>params[:contact],
      :creator_id=>id,
      :creator_name=>verify.name,
      :applicant_Id=>-1)
    if job.saved?
      {
        'message'=>'Successful'
      }.to_json
    else
      status 401
    end
  else
    status 401
  end
end

post '/accept/:jobid' do
  jobId = params[:jobid]
  userId = params[:user_id]
  job = Job.first(:id=>jobId)
  if(job)
    if job.applicant_id == -1
      job.update(:applicant_id=>userId)
      {
        'message'=>'Successful'
      }.to_json
    else
      status 401
    end
  else
    status 404
  end
end

#Get user's accepted jobs
get '/:user/jobs' do
  userId = params['user'].to_i
  #auth = params['auth_token']
  verify = User.first(:id=>userId)
  if(verify)
    content_type :json
    jobs = Job.all(:applicant_id=>userId)
    output = Array.new
    jobs.each do |job|
      obj = {
        'id'=>job.id,
        'title'=>job.title.to_s,
        'start_date'=>job.start_date.to_s,
        'end_date'=>job.end_date.to_s
      }
      output.push(obj)
    end
    output.to_json
  else
    status 401
  end
end

get '/:user/history' do
  userId = params['user'].to_i
  verify = User.first(:id=>userId)
  if(verify)
    content_type :json
    jobs = Job.all(:applicant_id=>userId, :finished=>true)
    output = Array.new
    jobs.each do |job|
      obj = {
        'id'=>job.id,
        'title'=>job.title.to_s,
        'start_date'=>job.start_date.to_s,
        'end_date'=>job.end_date.to_s
      }
      output.push(obj)
    end
    output.to_json
  else
    status 401
  end
end

get '/meta' do
  {
    'last_update'=> '2015-10-29 01:10:55'
  }.to_json
end

post '/finish/:jobid' do
  jobId = params['jobid'].to_i
  userId = params[:user_id].to_i
  auth = params[:auth_token]
  job = Job.first(:id=>jobId)
  verify = User.first(:id=>userId)
  if(job && verify && job.applicant_id==userId && verify.auth_token==auth)
    job.update(:finished=>true)
    archive = Archive.create(:comment=>params[:comment], :finish_date=>params[:finish_date], :latitude=>params[:latitude], :longitude=>params[:longitude])
    content_type :json
    {
      'message'=>'Successful'
    }.to_json
  else
    status 401
  end
end
