# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

def each_chapter
  return enum_for(:each_chapter) unless block_given?

  @toc_strings.each_with_index do |name, idx|
    number = idx + 1
    content = File.read("data/chp#{number}.txt")
    yield number, name, content
  end
end

def chapters_matching(query)
  results = []
  return results if query.nil? || query.strip.empty?

  each_chapter do |number, name, content|
    results << { number: number, name: name } if content.include?(query)
  end

  results
end

helpers do
  def plain_text_paragraph_enum(data_string)
    data_string.each_line('', chomp: true)
  end
end

before do
  @title = 'The Adventures of Sherlock Holmes'
  @toc_strings = File.read('data/toc.txt').each_line(chomp: true).to_a
end

not_found do
  redirect '/'
end

get '/' do
  @content_subhead = 'Table of Contents'

  erb :home
end

get '/chapter/:number' do |number|
  @chapter_num = number.to_i
  redirect '/' unless (1..@toc_strings.size).cover?(@chapter_num)

  @chapter_name = "Chapter #{@chapter_num} - #{@toc_strings[@chapter_num - 1]}"
  @chapter_data_string = File.read("data/chp#{@chapter_num}.txt")

  @title += " - #{@chapter_name}"
  @content_subhead = @chapter_name

  erb :chapter
end

get '/search' do
  @query = params[:query] || ''
  @results = chapters_matching(@query)
  erb :search
end
