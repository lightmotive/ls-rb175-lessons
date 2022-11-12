require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

TOC = File.read('data/toc.txt').each_line(chomp: true).to_a

get '/' do
  @title = 'The Adventures of Sherlock Holmes'
  @content_subhead = 'Table of Contents'
  erb :home
end

get '/chapter/:chapter_num' do |chapter_num|
  chapter_num = chapter_num.to_i.clamp(1, TOC.size)
  @chapter_name = "Chapter #{chapter_num} - #{TOC[chapter_num - 1]}"
  @chapter_paragraphs = File.read("data/chp#{chapter_num}.txt").each_line('', chomp: true)
  @title = "The Adventures of Sherlock Holmes - #{@chapter_name}"
  @content_subhead = @chapter_name
  erb :chapter
end
