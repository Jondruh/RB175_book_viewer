require 'tilt/erubis'
require "sinatra"
require "sinatra/reloader" if development?

helpers do
  def to_paragraph(text)
    text.split("\n\n").map.with_index do |paragraph, index|
      "<p id=#{index}>#{paragraph}</p>"
    end.join
  end

  def highlight(text, search)
    text.gsub(search, "<strong>#{search}</strong>")
  end
end

before do
  @title = "The Adventures of Sherlock Holmes"
  @contents = File.readlines("./data/toc.txt")
end

get "/" do
  erb :home
end

get "/chapters/:number" do 
  @chapter_number = params["number"].to_i
  
  redirect "/" unless (1..@contents.size).cover?(@chapter_number)

  @chapter_name = @contents[@chapter_number - 1]
  @chapter_title = "Chapter #{@chapter_number}: #{@chapter_name}"

  @chapter = File.read("./data/chp#{params["number"]}.txt")
  @chapter = to_paragraph(@chapter)
  erb :chapters
end

get "/search" do
  if params[:query]
    @search_hits = {}
  
    @contents.each_with_index do |chap_title, ind|
     chapter = File.read("./data/chp#{ind + 1}.txt").split("\n\n")

     paragraph_hits = []
     chapter.each_with_index do |paragraph, index|
       next unless paragraph.include?(params[:query])

       paragraph_hits << { 
                        text: highlight(paragraph, params[:query]),
                        chapter_num: (ind + 1), 
                        paragraph: index.to_s,
                        }
     end

     @search_hits[chap_title] = paragraph_hits unless paragraph_hits.empty?
    end
  end
 
  erb :search
end

not_found do
  redirect "/"
end

