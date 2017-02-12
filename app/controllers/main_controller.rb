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
    start_page_no = 1
    end_page_no = 0
    #Since the table of contents page lie within page number 20. Iterate and find the starting page number ,
    # if "table of contents or contents" words are present
    while !((reader.page(start_page_no).text.include? "Table of Contents") || (reader.page(start_page_no).text.include? "Contents") || (reader.page(start_page_no).text.include? "TableofContents"))
      start_page_no += 1
    end
    puts start_page_no
    #get the ending page of table of contents
    end_page_no = get_end(reader,start_page_no)
    puts end_page_no
    #Let titles be an empty string
    @titles = ""
    #Store all the titles in a string from starting page to ending page of table of contents
    for i in (start_page_no..end_page_no)
        @titles.concat(reader.page(i).text)
    end

    #Convert that string into an array removing all the empty lines
    @arr_of_titles = []

    @titles.each_line do |title|
      if (title != "\n") && !((title.include? "Preface") || (title.include? "TableofContents") || (title.include? "Table of Contents") || (title.include? "Contents"))
        title = title.gsub!(/[^0-9A-Za-z\t\r ]/, '')
        @arr_of_titles.push(title)
      end
    end

    @arr_of_titles.pop
    #Create an empty hash
    @map = {}
    #Store the 0th index of the hash with the title of the pdf page
    @map["0"] = @info
    @map["content"] = {}
    @count = 1


    @arr_of_titles.each do |line|
      @curr_line = {}
      #Let every title be an hash
      @curr_line["#{@count}"] =  Hash.new
      #Store the title in the key title
      @curr_line["#{@count}"]["title"] = line
      #Merge the curr_line to the main hash
      @map["content"].merge!(@curr_line)
      @count += 1
    end


    @map = swap(@map)

  end

private

def swap(map)
  #Iterate throuh all the titles
  for i in (1..@count) do
    #if hash has any titles then continue
    if map["content"]["#{i}"].present?
      #Intialize the sub titles a new hash inside the title hash
      map["content"]["#{i}"]["subt"] = Hash.new
      new_count = 1
      #Chech if the next title is present
        if map["content"]["#{i + new_count}"].present?
          #while next titles starting space more than that of the current title, store the next title in the sub titles hash
         while (map["content"]["#{i+new_count}"]["title"][/\A */].size > map["content"]["#{i}"]["title"][/\A */].size)
           store(i,i+new_count,new_count)
           new_count+=1
           #if next title is not present break the loop.
           if !(map["content"]["#{i + new_count}"].present?)
             break
           end
           #iterate again
         end
        end
     end
  end
  return map
end

def get_end(reader,start_page_no)
  # Let us count the number of characters in consecutive lines. If its more than 110 then it will be a paragraph.
  # Which proves that the page is one page ahead of the table of contents page.
  #Let the count of no of lines
  @no_of_lines = 0
  #Let the lines be an empty array
  @lines = []
  #store the temporary end page as the starting of table of contents page + 30
  tmp_end_page = start_page_no + 15
  #Store all the lines without any space of number inside the lines array
  for i in (start_page_no..tmp_end_page) do
          reader.page(i).text.each_line do |line|
            hash = Hash.new()
            hash["line"] = line.gsub(/[^A-Za-z]/, '')
            hash["page"] = i
            @lines.append(hash)
            @no_of_lines += 1
          end
  end
  for z in (0..@no_of_lines) do
      if @lines[z+1].present?
        if @lines[z]["line"].length + @lines[z+1]["line"].length > 110
          @end_page_no = @lines[z]["page"].to_i
          break
        end
      end
  end
  return @end_page_no - 1
end

def store(i,j,new_count)
    #Store the next title inside the subtitles hash of the current title
    @map["content"]["#{i}"]["subt"].store("#{new_count}",@map["content"]["#{j}"]["title"])
    #Delete the next title from titles hash
    @map["content"].delete("#{j}")
  end
end
