# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

helpers do
  def plain_text_paragraph_enum(data_string)
    data_string.each_line('', chomp: true)
  end

  def highlight_query(content, query, prefix: '<strong>', suffix: '</strong>')
    return content if query.nil? || query.empty?

    content.gsub(query, "#{prefix}#{query}#{suffix}")
  end
end

# ** Private helpers **

def each_chapter
  return enum_for(:each_chapter) unless block_given?

  @toc_strings.each_with_index do |name, idx|
    number = idx + 1
    content = File.read("data/chp#{number}.txt")
    yield number, name, content
  end
end

def paragraphs_matching(content, query)
  matches = []
  plain_text_paragraph_enum(content).each_with_index do |paragraph, idx|
    next unless paragraph.include?(query)

    matches << { number: idx + 1, content: paragraph }
  end

  matches
end

def chapters_matching(query)
  results = []
  return results if query.nil? || query.strip.empty?

  each_chapter do |number, name, content|
    paragraph_matches = paragraphs_matching(content, query)
    next if paragraph_matches.empty?

    results << { number: number, name: name, paragraphs: paragraph_matches }
  end

  results
end

# ** Routes **

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

  @query = params['query']
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
