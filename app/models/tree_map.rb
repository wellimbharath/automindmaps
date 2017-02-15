require 'pdf/reader'
require 'open-uri'
require 'json'

class TreeMap
  include ActiveModel::Model
  def initialize(path,link,id)
    if (File.size("#{path}/tree.json") == 0)
      # Get the pdf file
      io = open(link)
      reader = PDF::Reader.new(io)
      #Get the title of the file
      @name = reader.info[:Title]
      #Intitalize the start and end of the table of content page with zero
      start_page_no = 1
      end_page_no = 0
      #Since the table of contents page lie within page number 20. Iterate and find the starting page number ,
      # if "table of contents or contents" words are present
      while !((reader.page(start_page_no).text.include? "Table of Contents") || (reader.page(start_page_no).text.include? "Contents") || (reader.page(start_page_no).text.include? "CONTENTS") || (reader.page(start_page_no).text.include? "TableofContents"))
        start_page_no += 1
      end

      #get the ending page of table of contents
      end_page_no = get_end(reader,start_page_no)

      #Let titles be an empty string
      @titles = ""

      #Store all the titles in a string from starting page to ending page of table of contents
      for i in (start_page_no..end_page_no)
          @titles.concat("\n")
          @titles.concat(reader.page(i).text)
      end

      #Convert that string into an array removing all the empty lines
      @arr_of_titles = []

      @titles.each_line do |title|
        if (title != "\n") && !((title.include? "Preface") || (title.include? "TableofContents") || (title.include? "Table of Contents") || (title.include? "Contents"))
          title = title.gsub!(/[^0-9A-Za-z\t\r,' ]/, '')
          @arr_of_titles.push(title)
        end
      end

      @arr_of_titles.pop
      #Create an empty hash
      @map = Hash.new
      #Store the 0th index of the hash with the title of the pdf page
      @map["name"] = @info
      @map["children"] = []
      @count = 1

      @arr_of_titles.each do |line|
        @curr_line = Hash.new
        #Store the title in the key name
        @curr_line["name"] = line
        #Merge the curr_line to the main hash
        @map["children"].append(@curr_line)
      end
      @count = @map["children"].count

      consid_child(@map,@count)

      @count = @map["children"].count

      for i in (0..@count-2)
        @map["children"][i]["name"].strip!
        @map["children"][i]["name"].gsub!(/[^A-Za-z\t\r,' ]/, '')
      end
      File.open("#{path}/tree.json","w+") do |f|
        f.write(@map.to_json)
      end
    end
  end
  def consid_child(map,count)
    for i in (0..count-1) do
        if map["children"][i].present?
          map["children"][i]["children"] = []
          while !(map["children"][i+1].nil?) && map["children"][i+1].present? && (map["children"][i+1]["name"][/\A */].size > map["children"][i]["name"][/\A */].size)
            k = Hash.new
            k["name"] = map["children"][i+1]["name"].gsub(/[^A-Za-z\t\r,' ]/, '')
            if map["children"][i+1]["name"][/\A */].size > map["children"][i]["name"][/\A */].size
              map["children"][i]["children"].append(k)
              map["children"].delete(map["children"][i+1])
            end
          end
          if map["children"][i]["children"].count > 1
            consid_child(map["children"][i], map["children"][i]["children"].count)
          end
        end
    end
  end

  private

  def get_end(reader,start_page_no)
    # Let us count the number of characters in consecutive lines. If its more than 110 then it will be a paragraph.
    # Which proves that the page is one page ahead of the table of contents page.
    #Let the count of no of lines
    @no_of_lines = 0
    #Let the lines be an empty array
    @lines = []
    #store the temporary end page as the starting of table of contents page + 30
    tmp_end_page = start_page_no + 30
    #Store all the lines without any space or number inside the lines array
    for i in (start_page_no..tmp_end_page) do
            reader.page(i).text.each_line do |line|
              hash = Hash.new()
              hash["line"] = line.gsub(/[^A-Za-z]/, '')
              #store the page number
              hash["page"] = i
              #append the hash to the lines array
              @lines.append(hash)
              #increment the no of lines
              @no_of_lines += 1
            end
    end

    for z in (0..@no_of_lines) do
      #check if z+1 th index is present
        if @lines[z+1].present?
          #if no of characters in the two consecutive lines is more than 110 then we can make sure that its the begining of a paragraph
          if @lines[z]["line"].length + @lines[z+1]["line"].length > 110
            #Store the page no in an array
            @end_page_no = @lines[z]["page"].to_i
            break
          end
        end
    end
    #return the previous page of the paragraph containing page
    return @end_page_no - 1
  end

end
