# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

before do
  @title = 'Users with Interests'
  @users = YAML.load_file('data/users.yaml')
end

get '/' do
  erb :home
end

get '/user/:id' do |id|
  @title = "#{id} - Profile"
  @user = @users[id.to_sym]
  erb :user
end
