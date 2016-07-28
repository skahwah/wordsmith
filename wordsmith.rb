#!/usr/local/bin/ruby

=begin
wordmith.rb
=end

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'optparse'
require 'ostruct'
require 'yaml'

# This method changes text color to a supplied integer value which correlates to Ruby's color representation
def colorize(text, color_code)
	"\e[#{color_code}m#{text}\e[0m"
end

# This method changes text color to gray
def gray(text)
	colorize(text, 90)
end

# This method changes text color to red
def red(text)
  colorize(text, 31)
end

# This method changes text color to orange
def orange(text)
  colorize(text, 33)
end

# This method changes text color to blue
def blue(text)
	colorize(text, 34)
end

def title()
  puts gray("wordsmith v1.0")
  puts gray("Written by: Sanjiv \"Trashcan Head\" Kawa & Tom \"Pain Train\" Porter")
  puts gray("Twitter: @skawasec & @porterhau5")
  puts ""
end

# This method asks a user to set a state. The idea is that state is then used throughout the HTML scraping process
def states(state)

  if state.downcase == "all"
    puts "-- Generating output for all states --"
  elsif not @sources['states'][urlFormatter(state.downcase)].nil?
    # example values:
    # @stateKey - north%20carolina
    # @stateTitle - North Carolina
    # @stateUrl - North%20Carolina
    # @stateAbbrev - NC
    @stateKey = urlFormatter(@sources['states'][urlFormatter(state.downcase)]['title'].downcase)
    @stateTitle = @sources['states'][urlFormatter(state.downcase)]['title']
    @stateUrl = @stateTitle.gsub(/\s/,'%20')
    @stateAbbrev = @sources['states'][urlFormatter(state.downcase)]['abbrev']
    puts "-- State set to: #{@stateTitle}"
  else
    puts red("#{state} is an invalid state. Please type the state name or abbrevation. For example \"California\" or \"CA\".")
    abort
  end
end

# this method will check if a url is valid
def urlChecker(url)
  begin
    page = Nokogiri::HTML(open(url))
  rescue OpenURI::HTTPError => e
    puts "Can't access: #{url}"
    puts red("Error Message: #{e.message}")
    puts "Exiting this method!"
  end
end

# this method will replace any spaces in a state with %20 so that the URL is properly formatted
def urlFormatter(stateSet)
  if stateSet.include? "\s"
    # replace any spaces in the state with the URL equivilent
    @url = stateSet.gsub(/\s/,'%20')
  else
    # just return the original state
    @url = stateSet
  end
end

# this method will check to see if the file exists before it is processed.
def fileCheck(file)
  files = file

  if File.exist?(files) == false
    puts " "
    puts "Whoops!"
    puts "The file named #{files} does not exist and wordsmith needs that to process this request."
    puts "Please update the program using the force update function or unpack data.tar.gz"
    puts red("EXITING!")
    abort
  end
end

# this method will forcefully pull all data required for and store to HTML.
def pull()
  if not Dir.exists?('data') then Dir.mkdir('data') end
  puts blue("Downloading ~100MB of data. Please be patient.")
  puts ""
  pullAreaCodes()
  pullCities()
  pullNames()
  pullRoads()
  pullSports()
  pullZip()
end

# this method will pull all data required for sports teams per state and store to HTML.
def pullSports()

  url  = @sources['sports']
  page = urlChecker(url)
  sportsTeams = "data/sports/sports.html"
  puts "Grabbing USA sports teams for all states and storing to disk"
  output = File.open(sportsTeams,"w")
  # store the url above into a file named data/sports/sports.html
  output.write page
  output.close

  puts "Success, files stored in #{Dir.pwd}/data/"
  puts ""
end

# this method will pull all data required for cities and landmarks per state and store to HTML.
def pullCities()

  puts "Grabbing Cities, Landmarks, and College Sports for all states and storing to disk"

  count = 0
  until count == @statesArrLength
    stateKey = @statesArr.keys[count]
    state = urlFormatter(@statesArr.values[count]['title'])

    # cities
    citiesUrl = @sources['states'][stateKey]['cities'] % { :state => state }
    cities = urlChecker(citiesUrl)
    output = File.open("data/states/#{state}/cities.html","w")
    output.write cities
    output.close

    # landmarks
    landmarkUrl = @sources['states'][stateKey]['landmarks'] % { :state => state }
    landmark = urlChecker(landmarkUrl)
    output = File.open("data/states/#{state}/landmarks.html","w")
    output.write landmark
    output.close

    # colleges
    collegesUrl = @sources['states'][stateKey]['colleges'] % { :state => state }
    colleges = urlChecker(collegesUrl)
    output = File.open("data/states/#{state}/colleges.html","w")
    output.write colleges
    output.close

    count = count + 1

    # print status
    print "%.2f" % (count/@statesArrLength.to_f * 100)
    print "% "
  end
  puts ""
  puts "Success, files stored in #{Dir.pwd}/data/"
  puts ""
end

# this method will pull all data required for popular names in the US and store to HTML.
def pullNames()
  puts "Grabbing most common lastnames, first names, and baby names and and storing to disk"

  count = 0
  final = 19.0

  namesUrl = @sources['names']
  namesUrl.each{ |url|
    page = urlChecker(url)
    output = File.open("data/names/names-#{count}.html","w")
    # cycle through array, for each namesUrl, grab and store the HTML file to disk
    output.write page
    output.close
    count = count + 1
    print "%.2f" % (count/final * 100)
    print "% "
  }

  babyNamesUrl = @sources['babynames']
  babyNamesUrl.each{ |url|
    page = urlChecker(url)
    output = File.open("data/names/babynames-#{count}.html","w")
    # cycle through array, for each babyNamesUrl, grab and store the HTML file to disk
    output.write page
    output.close
    count = count + 1
    print "%.2f" % (count/final * 100)
    print "% "
  }
  puts ""
  puts "Success, files stored in #{Dir.pwd}/data/"
  puts ""
end

# this method will pull all data required for zip codes per state and store to HTML.
def pullZip()

  puts "Grabbing zip codes for all States and storing to disk"

  count = 0
  until count == @statesArrLength
    stateKey = @statesArr.keys[count]
    state = urlFormatter(@statesArr.values[count]['title'])

    # set the state in the specified URL
    url = @sources['states'][stateKey]['zip'] % { :state => state }

    zip = urlChecker(url)

    output = File.open("data/states/#{state}/zip.html","w")
    # cycle through array, for each state and store the HTML file containing zip codes to disk
    output.write zip
    output.close

    count = count + 1
    print "%.2f" % (count/@statesArrLength.to_f * 100)
    print "% "
  end
  puts ""
  puts "Success, files stored in #{Dir.pwd}/data/"
  puts ""
end

# this method will pull all area codes for each state and store to disk
def pullAreaCodes()
  puts "Grabbing area codes for all States and storing to disk"
  url = @sources['area']
  File.open("data/area/usa-area-codes.csv", "wb") do |saved_file|
    open(url, "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end

  puts "Success, file stored in #{Dir.pwd}/data/"
  puts ""
end

# this method will pull all roads for each state and store to disk
def pullRoads()
  puts "Grabbing streets and roads for all States and storing to disk"
  url = @sources['roads']
  File.open("roads.tar.gz", "wb") do |saved_file|
    open(url, "rb") do |read_file|
      saved_file.write(read_file.read)
    end
  end

  %x[tar -xf roads.tar.gz]
  %x[rm roads.tar.gz]

  puts "Success, file stored in #{Dir.pwd}/data/"
  puts ""
end

# this method will get all of the sports teams for a given state
def sportsTeams()
  url  = "data/sports/sports.html"
  fileCheck(url)
  page = urlChecker(url)
  # get a count of the table data attributs on the page
  tdLength = page.css('td').length.to_i

  # 0 represents the first table row which is the sports team name
  team = 0
  # 2 represents the third table row which is the state of the corresponding sports team
  state = 2
  teamsHash = Hash.new()

  until team == tdLength
    # key is the sports team name as this is unique
    key = page.css('td')[team].text
    # value is the state of the sports team
    value = page.css('td')[state].text
    teamsHash[key.to_s] = value.to_s
    # plus 7 to go back to the first element in the table, which is the name of the sports team
    team = team + 7
    # plus 7 to go back to the thrid element in the table, which is the state of the corresponding sports team
    state = state + 7
  end

  teams = []

  teamsHash.select{ |team, state|
    if state == @stateTitle
      # add all of the sports teams for a specific state into an array
      teams.push team.to_s
    end}

   if teams.empty?
     puts "Sports teams in #{@stateAbbrev}:  0"
   else
     teamspp = postProcessor(teams)
     @teams = @teams + teamspp
     if @quiet != true
       puts teamspp
       puts ""
     end
     puts "Sports teams in #{@stateAbbrev}:  #{teamspp.length}"
   end
end

# this method will get all of the cities and towns for a given state.
def cities()

  if @stateKey == "district%20of%20columbia"
    cities = ["Washington"]
    citiespp = postProcessor(cities)
    @cities = @cities + citiespp
    if @quiet != true
      puts citiespp
      puts ""
    end
    puts "City names in DC:    #{citiespp.length}"
  else
    url = "data/states/#{@stateUrl}/cities.html"
    fileCheck(url)
    page = urlChecker(url)

    # look for all table rows in the supplied URL as entries for cities and towns are likely to be in a table
    row = page.css('table.wikitable tr')
    # filter down to all table rows containing a hyperlink, as cities and towns are likley to be wrapped in "a href"
    cities = row.css('a').map {|city| city.text}
    # sort and delete duplicates, then delete any line that contains brackets
    cities = cities.sort.uniq.delete_if {|city| city.include?("]") }
    # delete any line that contains that has http
    cities = cities.delete_if {|city| city.include?("http") }
    # delete any line that contains that has a ; - typically coordinates
    cities = cities.delete_if {|city| city.include?(";") }
    # delete any line that has at least 2 consequtive numbers (year or neighbourhoods in city)
    cities = cities.delete_if {|city| city.match(/\d\d/) }
    # delete any empty line
    cities = cities.delete_if {|city| city.empty? }
    # delete any line where the first character of a string starts with a lower case letter
    cities = cities.delete_if {|city| city[0].match(/^[a-z]/)}
    # delete anything within parenthesis and the parenthesis themselves
    cities = cities.each {|city| city.gsub!(/\([^()]*\)/,'')}
    # replace \n
    cities = cities.each {|city| city.gsub!(/\n/,'')}
    # replace !
    cities = cities.each {|city| city.gsub!(/!/,'')}
    # replace the † character - typically used for references on wikipedia
    cities = cities.each {|city| city.gsub!(/†/,'')}
    # remove all trailing spaces from a string
    cities = cities.each {|city| city.gsub!(/\s+$/,'')}
    # perform another sort and uniq
    cities = cities.sort.uniq

    citiespp = postProcessor(cities)
    @cities = @cities + citiespp
    if @quiet != true
      puts citiespp
      puts ""
    end
    puts "City names in #{@stateAbbrev}:    #{citiespp.length}"
  end
end

def colleges()

  url = "data/states/#{@stateUrl}/colleges.html"
  fileCheck(url)
  page = urlChecker(url)

  # look for all table rows in the supplied URL as entries for colleges are likely to be in a table
  row = page.css('table.wikitable tr')
  # filter down to all table rows containing a td
  colleges = row.css('td').map {|college| college.text}
  # sort and delete duplicates, then delete any line that contains brackets
  colleges = colleges.sort.uniq.delete_if {|college| college.include?("]") }
  # delete any line that contains that has http
  colleges = colleges.delete_if {|college| college.include?("http") }
  # delete any line that contains that has a ; - typically coordinates
  colleges = colleges.delete_if {|college| college.include?(";") }
  # delete any line that has at least 2 consequtive numbers
  colleges = colleges.delete_if {|college| college.match(/\d\d/) }
  # delete any empty line
  colleges = colleges.delete_if {|college| college.empty? }
  # delete any line where the first character of a string starts with a lower case letter
  colleges = colleges.delete_if {|college| college[0].match(/^[a-z]/)}
  # delete anything within parenthesis and the parenthesis themselves
  colleges = colleges.each {|college| college.gsub!(/\([^()]*\)/,'')}
  # replace \n
  colleges = colleges.each {|college| college.gsub!(/\n/,'')}
  # replace !
  colleges = colleges.each {|college| college.gsub!(/!/,'')}
  # replace the † character - typically used for references on wikipedia
  colleges = colleges.each {|college| college.gsub!(/†/,'')}
  # remove all trailing spaces from a string
  colleges = colleges.each {|college| college.gsub!(/\s+$/,'')}
  # perform another sort and uniq
  colleges = colleges.sort.uniq

  collegespp = postProcessor(colleges)
  @colleges = @colleges + collegespp
  if @quiet != true
    puts collegespp
    puts ""
  end
  puts "College names in #{@stateAbbrev}: #{collegespp.length}"
end


# this method will get all of the landmarks for a state
def landmarks()

  url = "data/states/#{@stateUrl}/landmarks.html"
  fileCheck(url)
  page = urlChecker(url)
  # look for all table rows in the supplied URL as entries for landmarks are likely to be in a table
  row = page.css('table.wikitable tr')
  # grab the first td from each tr. this is likely going to contain a landmark
  landmark = row.xpath('./td[1]').map {|lm| lm.text}
  # delete any empty line
  landmark = landmark.delete_if {|lm| lm.empty? }
  # delete anything within parenthesis and the parenthesis themselves
  landmark = landmark.each {|lm| lm.gsub!(/\([^()]*\)/,'')}
  # replace \n
  landmark = landmark.each {|lm| lm.gsub!(/\n/,'')}
  # replace !
  landmark = landmark.each {|lm| lm.gsub!(/!/,'')}
  # delete anything within brackets and the brackets themselves
  landmark = landmark.each {|lm| lm.gsub!(/\[[^\[\]]*\]/,'')}
  # remove all trailing spaces from a string
  landmark = landmark.each {|lm| lm.gsub!(/\s+$/,'')}
  landmark = landmark.sort.uniq
  badChars = ["1","2","1*","2*","3#","3","4","5","Legend","Site\stype","",nil]
  temp = landmark - badChars

  landmarkpp = postProcessor(temp)
  @landmark = @landmark + landmarkpp
  if @quiet != true
    puts landmarkpp
    puts ""
  end
  puts "Landmarks in #{@stateAbbrev}:     #{landmarkpp.length}"
end

# this method will get all of the zip codes for a state
def zip()
  url = "data/states/#{@stateUrl}/zip.html"
  fileCheck(url)
  page = urlChecker(url)
  # focus on the left div column
  div = page.css('div#leftCol')
  # focus on the inner table
  table = div.css('table.inner_table')
  # grab all the table rows from the inner table
  row = table.css('tr')
  # grab the first table data element from each table row
  zip = row.css('td[1]').map {|n| n.text}
  # delete text that contains "zip codes for the state of x"
  zip.delete_at(0)
  # delete text that contains "zip codes"
  zip.delete_at(0)

  @zip = @zip + zip
  if @quiet != true
    puts zip
    puts ""
  end
  puts "Zip codes in #{@stateAbbrev}:     #{zip.length}"
end

# this method will get all of the area codes for a state
def areaCode()
  areaCodesFile = "data/area/usa-area-codes.csv"
  fileCheck(areaCodesFile)
  # grep the state name in the area codes csv file and place into an array called line
  stateLine = File.open(areaCodesFile).grep(/^#{@stateTitle}/).join(', ').split(',')
  # The first element contains the state name. Delete this.
  stateLine.delete_at(0)

  @areaCode = @areaCode + stateLine
  if @quiet != true
    puts stateLine
    puts ""
  end
  puts "Area codes in #{@stateAbbrev}:    #{stateLine.length}"
end

# this method will get all of the road names for a state
def roads()
  filename = "data/states/#{@stateUrl}/roads.txt"
  fileCheck(filename)
  file = File.open(filename, "rb")
  contents = file.read
  file.close
  roads = contents.split("\n")

  roadspp = postProcessor(roads)
  @roads = @roads + roadspp

  if @quiet != true
    puts roadspp
    puts ""
  end
 puts "Road names in #{@stateAbbrev}:    #{roadspp.length}"
end

=begin
this method will get 1) 12k most common surnames in USA. 2) 1.2k common male names in USA.
3) 2k common female names in USA. 4) 1k boys names from 2014 5) 1k girls names from 2014
=end
def names()

  namesFiles = Dir["data/names/*.html"]

  names = []

  namesFiles.each{ |file|
    fileCheck(file)
    page = urlChecker(file)
    # look for all table rows in the supplied file
    row = page.css('tr')
    # grab second td for babynames, first td for names
    if file.include? "babynames"
      currentName = row.xpath('./td[2]').map {|n| n.text}
    else
      currentName = row.xpath('./td[1]').map {|n| n.text}
    end
    names = names + currentName
  }

  allNames = names.map(&:downcase).map(&:capitalize).sort.uniq

  @allNames = @allNames + allNames
  if @quiet != true
    puts allNames
    puts ""
  end
  puts "Common names in USA: #{allNames.length}"
end

# Cross-platform way of finding an executable in the $PATH.
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

# run CeWL against the specified URL
def scrapeSingle(url)

  # check for CeWL executable
  cewlpath = which("cewl")
  if cewlpath.nil?
    puts red("cewl executable not found in path! Skipping URL.")
    puts red("See README for CeWL installation instructions.")
    return
  end

  puts "Running CeWL against: #{url}"
  cewl = %x[#{cewlpath} #{url}]

  # convert to array, remove first two entries (CeWL banner and blank line)
  # sort and uniq
  result = cewl.split("\n").drop(2).sort.uniq

  @cewl = postProcessor(result)
  puts ""
  if @cewl.nil?
    puts "#{url} seems to be incorrect. Please check it in a web browser and try again."
    puts "Total unique words that CeWL grabbed from #{url} is: 0"
  else
    if @quiet != true
      puts @cewl
      puts ""
    end
    puts "Total unique words that CeWL grabbed from #{url} is: #{@cewl.length}"
  end
end

# run CeWL against a wordlist containing multiple URLs
def scrapeMultiple(infile)
  input = infile
  fileCheck(input)
  allCewls = []

  count = 1
  lineCount = File.foreach(input).count

  # check for CeWL executable
  cewlpath = which("cewl")
  if cewlpath.nil?
    puts red("cewl executable not found in path! Skipping URLs.")
    puts red("See README for CeWL installation instructions.")
    return
  end

  File.foreach(input) do |url|
    puts "Running CeWL against: #{url.chomp} (#{count}/#{lineCount})"

    cewl = %x[#{cewlpath} #{url}]

    if cewl.include? "Unable to connect to the site"
      puts "-- Unable to connect to the site"
      count = count + 1
    else
      # remove first two entries (CeWL banner and blank line), append to array
      allCewls = allCewls + (cewl.split("\n").drop(2))
      puts "Total words that CeWL grabbed from #{url.chomp} is: #{cewl.length}"
      count = count + 1
    end
  end

  # sort and uniq
  result = allCewls.sort.uniq
  @allCewls = postProcessor(result)
  if @allCewls.nil?
    puts "All URLs seems to be incorrect. Please check them in a web browser and try again."
    puts "Total unique words that CeWL grabbed from is: 0"
  else
    if @quiet != true
      puts @allCewls
      puts ""
    end
  end

  puts "Total unique words that CeWL grabbed from all URLs is: #{@allCewls.length}"
end

# run all functions (-a) against the specified state
def all()
  sportsTeams()
  cities()
  colleges()
  landmarks()
  zip()
  areaCode()
  roads()
end

# usage examples
def examples()
  puts "Grab all of the cities and towns for California"
  puts "    ruby wordsmith.rb -s CA -c"
  puts "\nGrab all of the cities for California, Montana, and Florida"
  puts "    ruby wordsmith.rb -s CA,MT,FL -c"
  puts "\nGrab all sports teams for California, mangle the output"
  puts "    ruby wordsmith.rb -s CA -t -m"
  puts "\nGrab all road names for California, mangle the output, convert to lowercase"
  puts "    ruby wordsmith.rb -s CA -r -m -j"
  puts "\nGrab all landmarks for California with a minimum character length of 8"
  puts "    ruby wordsmith.rb -s CA -l -k 8"
  puts "\nGrab everything for California, write to file named CA.txt"
  puts "    ruby wordsmith.rb -s CA -a -o CA.txt"
  puts "\nCreate a mega wordlist containing all states with all options, quiet output, write to file named all.txt"
  puts "    ruby wordsmith.rb -s all -m -q -o all.txt"
  puts "\nRun CeWL against https://www.popped.io, mangle the output"
  puts "    ruby wordsmith.rb -d https://www.popped.io -m"
  puts "\nRun CeWL against list of URLs contained in urls.txt, write to file out.txt"
  puts "    ruby wordsmith.rb -i urls.txt -m -o out.txt"
  puts "\nGrab the most common male, female, baby and last names in the USA"
  puts "    ruby wordsmith.rb -n"
end

=begin
this will take the contents of an array that is given to it and perform various manipulation functions.
this includes, keeping the original state of the array
taking each line and splitting it on a space in to seperate words
removing all special characters from a word
=end
def postProcessor(array)

  #words to be manipulated
  inputArray = []
  array.each {|word| inputArray.push word.to_s}

  # array to store final output
  finalArr = []

  # split words by spaces before manipulating
  if @split
    count = 0
    length = array.length

    until count == length
      words = array[count].split()
      wlength = words.length
      wcount = 0
      until wcount == wlength
        inputArray.push words[wcount].to_s
        wcount = wcount + 1
      end
      count = count + 1
    end
  end

  # add pre-manipulated words
  inputArray.each {|word| finalArr.push word.to_s}

  # add words with special characters removed
  if @specials
    inputArray.each {|word| finalArr.push word.to_s.gsub(/[^0-9A-Za-z]/, '')}
  end

  # add words with spaces removed
  if @spaces
    inputArray.each {|word| finalArr.push word.to_s.gsub(/[ ]/, '')}
  end

  # remove words with less than @length characters
  if @length.nil? == false
    finalArr.delete_if {|word| word.length < @length}
  end

  if @lower
    finalArr.map!(&:downcase)
  end

  # sort and uniq
  @finalArr = finalArr.sort.uniq

  return @finalArr
end

# output file
def output(file)

  outputArr = Array.new

  if @teams.nil? == false
    @teams.each {|line| outputArr.push line.to_s}
  end

  if @cities.nil? == false
    @cities.each {|line| outputArr.push line.to_s}
  end

  if @colleges.nil? == false
    @colleges.each {|line| outputArr.push line.to_s}
  end

  if @landmark.nil? == false
    @landmark.each {|line| outputArr.push line.to_s}
  end

  if @areaCode.nil? == false
    @areaCode.each {|line| outputArr.push line.to_s}
  end

  if @zip.nil? == false
    @zip.each {|line| outputArr.push line}
  end

  if @roads.nil? == false
    @roads.each {|line| outputArr.push line.to_s}
  end

  if @allNames.nil? == false
    @allNames.each {|line| outputArr.push line.to_s}
  end

  if @cewl.nil? == false
    @cewl.each {|line| outputArr.push line.to_s}
  end

  if @allCewls.nil? == false
    @allCewls.each {|line| outputArr.push line.to_s}
  end

  if @allNames.nil? == false
    @allNames.each {|line| outputArr.push line.to_s}
  end

  outputArr.sort!.uniq!
  outputArr = outputArr.reject {|el| el.empty?}

  File.open(file,"w" ) do |f|
    outputArr.each {|line| f.puts(line)}
  end

  puts ""
  puts blue("#{outputArr.length} words written to: #{Dir.pwd}/#{file}")
end

# CLI Arguments
def cli()
  options = OpenStruct.new
  ARGV << '-h' if ARGV.empty?
  OptionParser.new do |opt|
    opt.banner = "Usage: ruby wordsmith.rb [options]"
    opt.on('Main Arguments:')
    opt.on('-s', '--state <states>', Array, 'Comma-delimited list of US states') { |o| options.stateArgs = o }
    opt.on('State Options:')
    opt.on('-a', '--all', 'Grab everything for the specified state') { |o| options.all = o }
    opt.on('-c', '--cities', 'Grab all city names for the specified state') { |o| options.cities = o }
    opt.on('-f', '--colleges', 'Grab all college sports for the specified state') { |o| options.colleges = o }
    opt.on('-l', '--landmarks', 'Grab all landmarks for the specified state') { |o| options.landmarks = o }
    opt.on('-p', '--phone', 'Grab all area codes for the specified state') { |o| options.phone = o }
    opt.on('-r', '--roads', 'Grab all road names in the specified state') { |o| options.roads = o }
    opt.on('-t', '--teams', 'Grab all major sports teams in the specified state') { |o| options.sports = o }
    opt.on('-z', '--zip', 'Grab all zip codes for the specified state') { |o| options.zip = o }
    opt.on('Miscellaneous Options:')
    opt.on('-d', '--domain DOMAIN', 'Set a URL for a web application that you want CeWL to scrape') { |o| options.url = o }
    opt.on('-e', '--examples', 'Show some usage examples') { |o| options.examples = o }
    opt.on('-i', '--infile FILE', 'Supply a file containing multiple URLs that you want CeWL to scrape') { |o| options.multi = o }
    opt.on('-n', '--names', 'Grab the most common male, female, baby and last names in the USA') { |o| options.names = o }
    opt.on('Output Options:')
    opt.on('-o', '--output FILE', 'The name of the output file') { |o| options.out = o }
    opt.on('-q', '--quiet', 'Don\'t show words generated, use with -o option') { |o| options.quiet = o }
    opt.on('-k', '--length LEN', Integer, 'Minumum length of word to include') { |o| options.length = o }
    opt.on('-j', '--lowercase', 'Convert all words to lowercase') { |o| options.lower = o }
    opt.on('-w', '--specials', 'Add words with special characters removed') { |o| options.specials = o }
    opt.on('-x', '--spaces', 'Add words with spaces removed') { |o| options.spaces = o }
    opt.on('-y', '--split', 'Split words by space and add') { |o| options.split = o }
    opt.on('-m', '--mangle', 'Add all permutations (-w, -x, -y)') { |o| options.mangle = o }
    opt.on('Management:')
    opt.on('-u', '--update', 'Update data from Internet sources') { |o| options.update = o }
  end.parse!

  stateArgs = options.stateArgs
  all = options.all
  cities = options.cities
  colleges = options.colleges
  examples = options.examples
  landmarks = options.landmarks
  @length = options.length
  @lower = options.lower
  @mangle = options.mangle
  multiUrl = options.multi
  names = options.names
  outputFile = options.out
  phone = options.phone
  @quiet = options.quiet
  roads = options.roads
  sports = options.sports
  @spaces = options.spaces
  @specials = options.specials
  @split = options.split
  url = options.url
  update = options.update
  zip = options.zip

  # output arrays
  @teams = []
  @cities = []
  @colleges = []
  @landmark = []
  @areaCode = []
  @zip = []
  @roads = []
  @allNames = []
  @allCewls = []
  @allNames = []

  # turn on all manipulation switches for mangle
  if @mangle == true
    @spaces = true
    @split = true
    @specials = true
  end

  @sources = YAML.load_file('sources.yml')

  # select state keys that are not two-letter abbreviations
  @statesArr = @sources['states'].select{ |x| not x.length == 2 }
  @statesArrLength = @statesArr.length.to_i

  # these options do need a state to be set in order to run
  # if "all" is in array, do all states & options
  if not stateArgs.nil? and stateArgs.any?{ |s| s.casecmp('ALL') == 0 }
    count = 0
    @statesArr.each {
      states(@statesArr.keys[count])
      all()
      count = count + 1
    }
    names()
  # else, loop through each state provided
  elsif not stateArgs.nil?
    stateArgs.each { |state|
      states(state)
      if all
        all()
      else
        if cities then cities() end
        if colleges then colleges() end
        if landmarks then landmarks() end
        if phone then areaCode() end
        if roads then roads() end
        if sports then sportsTeams() end
        if zip then zip() end
      end
    }
  end

  # these options do not need a state to be set in order to run
  if examples then examples() end
  if names then names() end
  if update then pull() end
  if not url.nil? then scrapeSingle(url) end
  if not multiUrl.nil? then scrapeMultiple(multiUrl) end
  if not outputFile.nil? then output(outputFile) end
end

=begin
Check to see if the correct directory structure exists
If the user double clicks on data.tar.gz then all foders will be listed within data/
Folders need to be listed independantly, like cewl/ data/ and roads/
=end
def firstRun()
  dataCheck = "./data/states/Arizona/roads.txt"
  sourcesCheck = "sources.yml"

  if File.exist?(dataCheck) == false || File.exist?(sourcesCheck) == false
    archiveCheck = "data.tar.gz"
    if File.exist?(archiveCheck) == false
      puts red("data.tar.gz not detected! Please run wordsmith with the force update option.")
      puts ""
    elsif File.exist?(dataCheck) == false
      puts blue("Hello new wordsmither! Just need to unpack some files.")
      %x[rm -rf data/]
      %x[tar -xf data.tar.gz]
      puts blue("Unpack completed!")
      cewlpath = which("cewl")
      if cewlpath.nil?
        puts ""
        puts orange("WARNING: CeWL not found in path. Install CeWL and put in path to use -d or -i options.")
        puts ""
      else
        puts ""
        puts blue("CeWL found: #{cewlpath}")
        puts ""
      end
    else
      puts red("sources.yml not found. Aborting.")
      abort
    end
  end
end

title()
firstRun()
cli()
