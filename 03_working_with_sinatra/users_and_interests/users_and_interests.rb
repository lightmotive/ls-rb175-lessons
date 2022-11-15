# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

def calculate_user_stats
  interest_count = @users.values.reduce(0) do |sum, user_detail|
    sum + user_detail[:interests].size
  end
  @user_stats = { count: @users.keys.size, interest_count: interest_count }
end

before do
  @title = '* Users *'
  @users = YAML.load_file('data/users.yaml')
end

helpers do
  def user_stats
    calculate_user_stats
    "There are #{@user_stats[:count]} users with a total of #{@user_stats[:interest_count]} interests."
  end
end

get '/' do
  erb :home
end

get '/user/:id' do |id|
  @title = "#{id} - Profile"
  @user = @users[id.to_sym]
  erb :user
end
