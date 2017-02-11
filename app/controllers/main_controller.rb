require 'pdf/reader'
require 'open-uri'
class MainController < ApplicationController

  def index
    # Get the pdf file
    io = open("#{Rails.public_path}/ml_proj.pdf")
    reader = PDF::Reader.new(io)
    #Get the title of the file
    @info = reader.info[:Title]

    #Intitalize the start and end of the table of content page with zero
    start_page_no = 0
    end_page_no = 0

    #Since the table of contents page lie within page number 20. Iterate and find the starting page number ,
    # if "table of contents or contents" words are present
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

    # Usually the table of contents page end with index so if that word present in the page mark it as end page
    reader.pages.each do |page|
          if page.number > start_page_no
            text = page.text
            if (text.include? "index") || (text.include? "Preface")
              end_page_no = page.number
              break
            end
          end
    end
    #Let titles be an empty string
    @titles = ""
    #Store all the titles in a string from starting page to ending page of table of contents
    reader.pages.each do |page|
      if (page.number >= start_page_no) && (page.number <= end_page_no)
        @titles.concat(page.text)
      end
    end

    #Convert that string into an array removing all the empty lines
    @arr_of_titles = []

    @titles.each_line do |title|
      if (title != "\n") && !((title.include? "TableofContents") || (title.include? "Table of Contents") || (title.include? "Contents"))
        @arr_of_titles.push(title)
      end
    end

    #Create an empty hash
    @map = {}
    #Store the 0th index of the hash with the title of the pdf page
    @map["0"] = @info
    @map["content"] = {}
    count = 1


    @arr_of_titles.each do |line|
      @curr_line = {}
      #Let every title be an hash
      @curr_line["#{count}"] =  Hash.new
      #Store the title in the key title
      @curr_line["#{count}"]["title"] = line
      #Merge the curr_line to the main hash
      @map["content"].merge!(@curr_line)
      count += 1
    end

    #Iterate throuh all the titles
    for i in (1..count) do
      #if hash has any titles then continue
      if @map["content"]["#{i}"].present?
        #Intialize the sub titles a new hash inside the title hash
        @map["content"]["#{i}"]["subt"] = Hash.new
        new_count = 1
        #Chech if the next title is present
          if @map["content"]["#{i + new_count}"].present?
            #while next titles starting space more than that of the current title, store the next title in the sub titles hash
           while @map["content"]["#{i+new_count}"]["title"][/\A */].size > @map["content"]["#{i}"]["title"][/\A */].size
             store(i,i+new_count)
             new_count+=1
             #if next title is not present break the loop.
             if !(@map["content"]["#{i + new_count}"].present?)
               break
             end
             #iterate again
           end
         end
      end
    end
  end

  def store(i,j)
    #Store the next title inside the subtitles hash of the current title
    @map["content"]["#{i}"]["subt"].store("#{j}",@map["content"]["#{j}"])
    #Delete the next title from titles hash
    @map["content"].delete("#{j}")
  end
