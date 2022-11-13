# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

def toc_strings
  File.read('data/toc.txt').each_line(chomp: true).to_a
end

get '/' do
  @toc_strings = toc_strings

  @title = 'The Adventures of Sherlock Holmes'
  @content_subhead = 'Table of Contents'

  erb :home
end

get '/chapter/:number' do |number|
  @toc_strings = toc_strings

  @chapter_num = number.to_i.clamp(1, @toc_strings.size)
  @chapter_name = "Chapter #{@chapter_num} - #{@toc_strings[@chapter_num - 1]}"
  @chapter_paragraphs = File.read("data/chp#{@chapter_num}.txt")
                            .each_line('', chomp: true)

  @title = "The Adventures of Sherlock Holmes - #{@chapter_name}"
  @content_subhead = @chapter_name

  erb :chapter
end
