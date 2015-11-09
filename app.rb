require 'sinatra'
require 'rubygems'
require 'json'
require 'securerandom'
require 'dm-core'
require 'dm-migrations'
require 'aws/s3'
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
      'auth_token'=>verify.auth_token,
      'creator_name'=>verify.name
    }.to_json
  end
end

get '/users' do
  users = User.all
  arr = Array.new
  users.each do |user|
    obj = {
      'id'=>user.id,
      'username'=>user.username,
      'password'=>user.password,
      'name'=>user.name,
      'auth_token'=>user.auth_token
    }
    arr.push(obj)
  end
  arr.to_json
end

#REGISTER FROM MOBILE PHONE
post '/register' do
  username = params[:username]
  password = params[:password]
  name = params[:creator_name]
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
  jobId = params['id'].to_i
  result = Job.get(jobId)
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
      'creator_name'=>result.creator_name,
      'applicant_id'=>result.applicant_id
    }.to_json
  else
    status 404
  end
end

post '/jobs' do
  id = params[:user_id].to_i
  auth_token = params[:auth_token]
  count = User.count(:id=>id)
  verify = User.get(id)
  if(count>0)
    job=Job.create(
      :title=>params[:title],
      :description=>params[:description],
      :start_date=>params[:start_date],
      :end_date=>params[:end_date],
      :reward=>params[:reward],
      :contact=>params[:contact],
      :creator_id=>id,
      :creator_name=>verify.name,
      :applicant_id=>-1)
    if job.saved?
      {
        'message'=>'Successful'
      }.to_json
    else
      status 404
    end
  else
    status 401
  end
end

post '/edit/:jobid' do
  jobId = params['jobid'].to_i
  userId = params[:user_id].to_i
  job = Job.get(jobId)
  counter = Job.count(:id=>jobId)
  if(counter==0)
    status 404
  elsif job.creator_id == userId
    job.update(
      :title=>params[:title],
      :description=>params[:description],
      :start_date=>params[:start_date],
      :end_date=>params[:end_date],
      :reward=>params[:reward],
      :contact=>params[:contact]
      )
    {
      'message'=>'Successful'
    }.to_json
  else
    status 401
  end
end

post '/accept/:jobid' do
  jobId = params[:jobid].to_i
  userId = params[:user_id].to_i
  job = Job.get(jobId)
  count = User.count(:id=>userId)
  if(job && count>0)
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
  verify = User.get(userId)
  if(verify)
    content_type :json
    jobs = Job.all(:applicant_id => userId, :finished=>false)
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

get '/:user/created' do
  userId = params['user'].to_i
  verify = User.get(userId)
  if(verify)
    jobs = Job.all(:creator_id=>userId)
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
  job = Job.get(jobId)
  verify = User.get(userId)
  if(job.applicant_id==userId)
    job.update(:finished=>true)

    archive = Archive.create(
      :comment=>params[:comment],
      :finish_date=>params[:finish_date],
      :address=>params[:address],
      :image=>params[:image],
      :job_id=>jobId
      )

    content_type :json
    {
      'message'=>'Successful'
    }.to_json
  else
    status 401
  end
end

get '/archive/:job_id' do
  jobId = params['job_id'].to_i
  job = Job.get(jobId)
  archive = Archive.first(:job_id=>jobId)
  if(job && archive)
    {
      'id'=>job.id,
      'title'=>job.title,
      'description'=>job.description,
      'start_date'=>job.start_date,
      'end_date'=>job.end_date,
      'reward'=>job.reward,
      'contact'=>job.contact,
      'creator_id'=>job.creator_id,
      'creator_name'=>job.creator_name,
      'applicant_id'=>job.applicant_id,
      'image'=>archive.image,
      'address'=>archive.address,
      'finish_date'=>archive.finish_date,
      'comment'=>archive.comment
    }.to_json
  else
    status 404
  end
end
