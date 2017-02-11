require 'pdf/reader'
require 'open-uri'
class MainController < ApplicationController

  def index
    io = open("#{Rails.public_path}/ml_proj.pdf")
    reader = PDF::Reader.new(io)
    @info = reader.info[:Title]

    start_page_no = 0
    end_page_no = 0

    reader.pages.each do |page|
        if page.number == 20
          break
        end
        text = page.text
        if ((text.include? "Table of Contents") || (text.include? "Contents") || (text.include? "TableofContents"))
          start_page_no = page.number
          break
        end
    end
    @titles = " "
    reader.pages.each do |page|
      if (page.number == start_page_no)
          @titles.concat(page.text)
      end
    end
    @arr_of_titles = []

    @titles.each_line do |title|
      if (title != "\n") && !((title.include? "TableofContents") || (title.include? "Table of Contents") || (title.include? "Contents"))
        @arr_of_titles.push(title)
      end
    end

    reader.pages.each do |page|
          if page.number > start_page_no
            text = page.text
            if (text.include? @arr_of_titles[0].inspect) || (text.include? "index") || (text.include? "Preface")
              end_page_no = page.number
              break
            end
          end
    end

    @titles = ""

    reader.pages.each do |page|
      if (page.number >= start_page_no) && (page.number <= end_page_no)
        @titles.concat(page.text)
      end
    end

    @arr_of_titles = []
    @titles.each_line do |title|
      if (title != "\n") && !((title.include? "TableofContents") || (title.include? "Table of Contents") || (title.include? "Contents"))
        @arr_of_titles.push(title)
      end
    end

    @map = {}
    @map["0"] = @info
    @map["content"] = {}
    count = 1

    @arr_of_titles.each do |line|
      @curr_line = {}
      @curr_line["#{count}"] =  Hash.new
      @curr_line["#{count}"]["title"] = line
      @map["content"].merge!(@curr_line)
      count += 1
    end

    for i in (1..count) do
      if @map["content"]["#{i}"].present?
        @map["content"]["#{i}"]["subt"] = Hash.new
        new_count = 1
          if @map["content"]["#{i + new_count}"].present?
           while @map["content"]["#{i+new_count}"]["title"][/\A */].size > @map["content"]["#{i}"]["title"][/\A */].size
             store(i,i+new_count)
             new_count+=1
             if !(@map["content"]["#{i + new_count}"].present?)
               break
             end
           end
         end
      end
    end
  end

  def store(i,j)
    @map["content"]["#{i}"]["subt"].store("#{j}",@map["content"]["#{j}"])
    @map["content"].delete("#{j}")
  end
