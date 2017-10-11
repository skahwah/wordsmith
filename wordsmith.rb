#!/usr/bin/ruby env
#Encoding: UTF-8

require 'ostruct'
require 'optparse'
require 'csv'
require 'yaml'

# Print the title of the program on run
def title()
  puts "wordsmith v2.0.7"
  puts "Written by: Sanjiv \"Trashcan Head\" Kawa & Tom \"Pain Train\" Porter"
  puts "Twitter: @hackerjiv & @porterhau5"
  puts ""
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

# -E flag will print examples
def examples()
  puts "Input names:"
  puts "------------"
  puts "Valid inputs for wordsmith (using -I option) are based on nodes located in the \"data\" directory."
  puts "The top-level nodes are countries labeled by their 3-letter ISO Country Code:"
  puts "    data/gbr : Great Britain"
  puts "    data/usa : United States"
  puts "    data/deu : Germany"
  puts "    etc."
  puts "\nSome countries are divided into states, provinces, counties, or municipalities. These child nodes"
  puts "are nested beneath the parent:"
  puts "    data/can/on : Ontario, Canada"
  puts "    data/usa/nc/raleigh : Raleigh, NC, USA"
  puts "    data/gbr/eng/sx/east_sussex : East Sussex, Sussex, England, Great Britain"
  puts "\nInputs for wordsmith use these node paths, but with a hyphen (-) delimiter:"
  puts "    ruby wordsmith.rb -I gbr [options]"
  puts "    ruby wordsmith.rb -I can-on [options]"
  puts "    ruby wordsmith.rb -I usa-nc-raleigh [options]"
  puts "\nIf you prefer to not dig through the \"data\" directory looking for potential inputs or attributes,"
  puts "use -C to show children nodes for a given input:"
  puts "    ruby wordsmith.rb -I all -C         (show all potential nodes)"
  puts "    ruby wordsmith.rb -I usa -C         (show children nodes of USA)"
  puts "    ruby wordsmith.rb -I gbr-eng -C     (show children nodes of England)"
  puts "\nAlternatively, inputs can also be user-defined through the use of the \"regions.csv\" file. Wordsmith"
  puts "ships with a few regions already defined, such as:"
  puts "    Continents    : africa, asia, europe, etc. "
  puts "    US regions    : southeast, newengland, greatlakes, etc."
  puts "    Unions/Assoc. : eu, asean, nafta, etc."
  puts "\nThese region aliases can be found by inspecting \"regions.csv\" or by using the -R option:"
  puts "    ruby wordsmith.rb -R"
  puts "\nBy supplying a number (N) to the -I option, inputs will instead be the N most populous countries."
  puts "The below example will use the 10 most populous countries as input:"
  puts "    ruby wordsmith.rb -I 10 [options]"
  puts ""
  puts "Attributes:"
  puts "-----------"
  puts "Each node may have one or more attributes, such as cities, roads, colleges, etc. Wordsmith will recurse"
  puts "every child node and grab data for the specified attribute. For example, the following syntax starts at"
  puts "the top-level \"usa\" node and recurses into every sub-directory looking for zip codes:"
  puts "    ruby wordsmith.rb -I usa -z"
  puts "\nSome attributes are widely-used, such as roads (-r), cities (-c), and a handful of others. Use the -h"
  puts "option to see a listing of those attributes. Some attributes may be unique to an area and don't have a"
  puts "dedicated option. These can still be grabbed by using the -b option. The -b option will look for all"
  puts "txt files that are not one of attributes with a dedicated option. For example, if someone generated data"
  puts "for all of the lakes in Minnesota and placed it in \"data/usa/mn/lakes.txt\", this can be grabbed using:"
  puts "    ruby wordsmith.rb -I usa-mn -b"
  puts "\nExtending wordsmith to incorporate new data is as simple as creating a \".txt\" file in the proper data"
  puts "directory. If you have data that you'd think would benefit other users, please connect with us on GitHub."
  puts ""
  puts "Basic usage:"
  puts "------------"
  puts "Show all children nodes and attributes for Great Britain"
  puts "    ruby wordsmith.rb -I gbr -C"
  puts "\nGrab all of the most popular names for USA"
  puts "    ruby wordsmith.rb -I usa -n"
  puts "\nGrab all of the zip codes for California"
  puts "    ruby wordsmith.rb -I usa-ca -z"
  puts "\nGrab all of the sports teams for Charlotte, NC, USA"
  puts "    ruby wordsmith.rb -I usa-nc-charlotte -t -m"
  puts "\nGrab all of the landmarks for California, Montana, and Florida"
  puts "    ruby wordsmith.rb -I usa-ca,usa-mt,usa-fl -l"
  puts "\nGrab all of the cities for the 25 most populous countries"
  puts "    ruby wordsmith.rb -I 25 -c"
  puts ""
  puts "\nUsing regions:"
  puts "--------------"
  puts "Show regions defined in regions.csv"
  puts "    ruby wordsmith.rb -R"
  puts "\nGrab all of the cities for the European Union"
  puts "    ruby wordsmith.rb -I eu -c"
  puts "\nGrab all of the roads for New England (U.S.)"
  puts "    ruby wordsmith.rb -I newengland -r"
  puts ""
  puts "\nOutput formatting:"
  puts "------------------"
  puts "Grab all colleges for California, mangle the output, convert to lowercase"
  puts "    ruby wordsmith.rb -I usa-ca -f -m -j"
  puts "\nGrab all roads for England with a minimum character length of 8"
  puts "    ruby wordsmith.rb -I gbr-eng -r -k 8"
  puts "\nGrab everything for Italy, write to file named italy.txt"
  puts "    ruby wordsmith.rb -I ita -a -o italy.txt"
  puts "\nCreate a mega wordlist containing all countries with all options, quiet output, write to file named all.txt"
  puts "    ruby wordsmith.rb -I all -a -m -q -o all.txt"
  puts ""
  puts "\nWeb scraping:"
  puts "-------------"
  puts "Run CeWL against https://www.popped.io, mangle the output"
  puts "    ruby wordsmith.rb -d https://www.popped.io -m"
  puts "\nRun CeWL against list of URLs contained in urls.txt, write to file out.txt"
  puts "    ruby wordsmith.rb -i urls.txt -m -o out.txt"
  exit
end

# show children nodes and their attributes, basically a tree view
def show_children(inputs)
  puts "Format:"
  puts "boundary-name : attribute1 attribute2 attribute3 etc."

  inputs.each do |input|
    subdirs = Dir.glob("#{input}/**/*/").sort
    files = Dir.glob("#{input}/*.txt").sort
    if not subdirs.empty? or not files.empty?
      puts ""
      # change "./data/abc/de/fegh" to "abc-de-fegh"
      dir = "#{input.sub(/^.\/data\//, '').gsub(/\//,'-').chomp("-")}"
      out = dir
      if not files.empty?
        out = "#{out} : "
        files.each do |f|
          out = out + " " + f.split("/").last.split(".").first
        end
      end
      puts "#{out}\n"

      subdirs.each do |subdir|
        subdirout = "#{subdir.sub(/^.\/data\//, '').gsub(/\//,'-').chomp("-")}"
        depth = subdirout.count("-") - dir.count("-")
        out = "|   " * (depth - 1) + "|-- " + subdirout
        files = Dir.glob("#{subdir}*.txt").sort
        if not files.empty?
          out = "#{out} : "
          files.each do |f|
            out = out + " " + f.split("/").last.split(".").first
          end
        end
        puts out
      end
    end
  end
  exit
end

# show defined regions from regions.csv
def show_regions()
  regions = CSV.read('./data/regions.csv')
  regions.each do |region|
    # skip comments and improperly-formatted lines in CSV
    next unless region.length == 3 and not region[0].start_with? '#'
    puts "Alias:       #{region[0]}"
    puts "Description: #{region[1]}"
    puts "Members:     #{region[2]}"
    puts ""
  end

  puts "[*] Regions can be modified by editing data/regions.csv"
  exit
end

@boundaries = []

# check to see if the user supplied input is a region
def is_region(regions,boundary)
  # first, check regions for each input
  found = false
  boundaries = []
  regions.each do |region|
    # skip comments and improperly-formatted lines in CSV
    next unless region.length == 3 and not region[0].start_with? '#'
    # if provided arg is the name of first CSV row element
    if boundary.casecmp(region[0]) == 0
      found = true
      # parse out locations from last CSV row element
      region[2].split.each do |r|
        boundaries = is_region(regions,r)
      end
    end
  end
  if not found
    @boundaries.push(boundary)
  end
end

# verify each provided input is legitimate
def validate_boundaries(options)
  # boundaries is for elements to check in data/ path
  boundaries = []
  # inputs is return array
  inputs = []

  regions = CSV.read('data/regions.csv')

  options.input.each do |boundary|
    is_region(regions,boundary)
    boundaries = @boundaries
  end

  # verify each boundary's data path can be found
  boundaries.each do |boundary|
    dir_path = "./data"
    nodes = boundary.split("-")
    depth = nodes.length
    count = 0

    while count < depth
      dir_path = "#{dir_path}/#{nodes[count].downcase()}"
      if not Dir.exist?(dir_path)
        puts "[!] Exiting - input \'#{boundary}\' not found!"
        abort
      elsif count == depth - 1
        inputs.push(dir_path)
      end
      count += 1
    end
  end

  return inputs.sort.uniq
end

# run CeWL against the specified URL
def scrapeSingle(options)

  # check for CeWL executable
  cewlpath = which("cewl")
  if cewlpath.nil?
    puts "[!] cewl executable not found in path! Skipping URL."
    puts "[*] See README for CeWL installation instructions."
    return
  end

  url = options.url

  puts "[+] Running CeWL against: #{url}"
  cewl = %x[#{cewlpath} #{url}]

  # convert to array, remove first two entries (CeWL banner and blank line)
  # sort and uniq
  result = cewl.split("\n").drop(2).sort.uniq

  if not result.empty?
    cewlpp = []
    cewlpp = post_processor(nil, options, result)
    if not options.quiet
      puts cewlpp
      puts ""
    end
    puts "[*] Total unique words that CeWL grabbed from #{url} is: #{cewlpp.length}"
  else
    puts "[!] #{url} seems to be incorrect. Please check it in a web browser and try again."
    puts "[*] Total unique words that CeWL grabbed from #{url} is: 0"
  end
end

# run CeWL against a wordlist containing multiple URLs
def scrapeMultiple(options)

  # check for CeWL executable
  cewlpath = which("cewl")
  if cewlpath.nil?
    puts "[!] cewl executable not found in path! Skipping URLs."
    puts "[*] See README for CeWL installation instructions."
    return
  end

  input = options.multi

  if File.exist?(input) == false
    puts " "
    puts "[!] File: #{input} does not exist! Skipping URLs."
    return
  end

  allCewls = []
  count = 1
  lineCount = File.foreach(input).count

  File.foreach(input) do |url|
    puts "[+] Running CeWL against: #{url.chomp} (#{count}/#{lineCount})"

    cewl = %x[#{cewlpath} #{url}]

    if cewl.include? "Unable to connect to the site"
      puts "-- Unable to connect to the site"
      count += 1
    else
      cewlarr = cewl.split("\n").drop(2).sort.uniq
      allCewls = allCewls + cewlarr
      puts "[*] Total words that CeWL grabbed from #{url.chomp} is: #{cewlarr.length}"
      count += 1
    end
  end

  # convert to array, remove first two entries (CeWL banner and blank line)
  # sort and uniq
  result = allCewls.sort.uniq

  if not result.empty?
    allCewlspp = []
    allCewlspp = post_processor(nil, options, result)
    if not options.quiet
      puts allCewlspp
      puts ""
    end
    puts "[*] Total unique words that CeWL grabbed from all URLs is: #{allCewlspp.length}"
  else
    puts "[!] All URLs seems to be incorrect. Please check them in a web browser and try again."
    puts "[*] Total unique words that CeWL grabbed from all URLS is: 0"
  end
end

# all data eventually gets shoved into this function where all post-processing occurs
def post_processor(dir_path, options, array)

  #words to be manipulated
  inputArray = []
  array.each {|word| inputArray.push word.to_s.chomp}

  # array to store staged and final output
  stageArr = []
  finalArr = []

  # split words by spaces before manipulating
  if options.split
    count = 0
    length = array.length

    until count == length
      words = array[count].split()
      wlength = words.length
      wcount = 0
      until wcount == wlength
        inputArray.push words[wcount].to_s
        wcount += 1
      end
      count += 1
    end
  end

  # add pre-manipulated words
  inputArray.each {|word| stageArr.push word.to_s}

  # add words with special characters removed
  if options.specials
    inputArray.each {|word| stageArr.push word.to_s.gsub(/[^0-9A-Za-z]/, '')}
  end

  # add words with spaces removed
  if options.spaces
    inputArray.each {|word| stageArr.push word.to_s.gsub(/[ ]/, '')}
  end

  # add stageArr to finalArr before output options
  stageArr.each {|word| finalArr.push word.to_s}

  # prepend/append area codes to all words
  if options.prependphone || options.appendphone
    # use usa for religion/language phones for now
    phone_file = ""
    if dir_path.nil?
      phone_file = Dir.glob("usa/**/areacodes.txt")
    else
      phone_file = Dir.glob("#{dir_path}/**/areacodes.txt")
    end

    phone_file.each do |f|
      file = File.open(f, "rb", :encoding => "ISO-8859-1:UTF-8")
      contents = ""
      contents = file.read
      file.close
      contents = contents.split("\n")
      if options.prependphone
        stageArr.each {|word|
          contents.each {|code|
            finalArr.push code + word } }
      end
      if options.appendphone
        stageArr.each {|word|
          contents.each {|code|
            finalArr.push word + code } }
      end
    end
  end

  # prepend/append zip codes to all words
  if options.prependzip || options.appendzip
    # use usa for religion/language zips for now
    zip_file = ""
    if dir_path.nil?
      zip_file = Dir.glob("usa/**/zipcodes.txt")
    else
      zip_file = Dir.glob("#{dir_path}/**/zipcodes.txt")
    end

    zip_file.each do |f|
      file = File.open(f, "rb", :encoding => "ISO-8859-1:UTF-8")
      contents = ""
      contents = file.read
      file.close
      contents = contents.split("\n")
      if options.prependzip
        stageArr.each {|word|
          contents.each {|code|
            finalArr.push code + word } }
      end
      if options.appendzip
        stageArr.each {|word|
          contents.each {|code|
            finalArr.push word + code } }
      end
    end
  end

  # prepend user-supplied wordlist
  if options.prependwordlist
    file = File.open(options.prependwordlist, "rb", :encoding => "ISO-8859-1:UTF-8")
    contents = ""
    contents = file.read
    file.close
    contents = contents.split("\n")
    stageArr.each {|word|
      contents.each {|ele|
        finalArr.push ele + word } }
  end

  # append user-supplied wordlist
  if options.appendwordlist
    file = File.open(options.appendwordlist, "rb", :encoding => "ISO-8859-1:UTF-8")
    contents = ""
    contents = file.read
    file.close
    contents = contents.split("\n")
    stageArr.each {|word|
      contents.each {|ele|
        finalArr.push word + ele } }
  end

  # remove words with less than options.minlength characters
  if options.minlength.nil? == false
    finalArr.delete_if {|word| word.length < options.minlength}
  end

  # remove words with more than options.maxlength characters
  if options.maxlength.nil? == false
    finalArr.delete_if {|word| word.length > options.maxlength}
  end

  # remove words that don't have at least 3 out of 4 cases (number, special, upper, lower)
  if options.default
    finalArr.delete_if {|word| not_complex(word)}
  end

  if options.lower
    finalArr.map!(&:downcase)
  end

  # sort and uniq
  if options.usergenerate
    retArr = finalArr
  else
    retArr = finalArr.uniq.sort
  end

  @finalArr = (@finalArr + retArr)

  return retArr
end

# check if a word doesn't meet Windows default complexity requirements of 3 out of 4 cases
def not_complex(word)
  cases = 0
  if (word =~ /\d/) then cases += 1 end # numerics
  if (word =~ /[a-z]/) then cases += 1 end # lowers
  if (word =~ /[A-Z]/) then cases += 1 end # uppers
  if (word =~ /[^a-zA-Z\d]/) then cases += 1 end # specials

  if cases < 3 then return true else return false end
end

# easy way to read files line-by-line into an array
def file_to_arr(f)
  file = File.open(f, "rb", :encoding => "UTF-8") # possibly change to ISO-8859-1:UTF-8?
  contents = file.read
  file.close
  arr = contents.downcase.split("\n")
  return arr
end

# out to file
def output(file)

  @finalArr.sort!.uniq!
  @finalArr = @finalArr.reject {|el| el.empty?}

  File.open(file,"w" ) do |f|
    @finalArr.each {|line| f.puts(line)}
  end

  puts ""
  puts "[*] #{@finalArr.length} words written to: #{Dir.pwd}/#{file}"
end

# the cia.txt files are structured, this breaks them down into a list of unique words
def format_cia_demographics(contents)
  word_array = Array.new
  symbols_arr = ["\,","$",";",".","!","(",")","*","%","@","^","&",":","\'","\"","/","\\","|","[","]","=","\”","\“","?","<a","+"]

  contents.split(" ").each do |word|
    symbols_arr.each do |symbol|
      word.gsub!(symbol,"")
        word_array.push word
      end
  end

  word_array.delete_if { |string| string.include?("hrefrankorder") }
  word_array.sort!.uniq!
  word_string = word_array.join("\n")
  return word_string
end

def generate_users(dir_path, options)
  fnames = []
  lnames = []
  data = []

  # enum the first names if we're using an option that includes full first names, otherwise return the alphabet
  if options.genfirstname
    if File.exist?("#{dir_path}/fnames.txt") == false then return end
    if options.namedepth == 0
      fnames = File.foreach("#{dir_path}/fnames.txt")
    else
      fnames = File.foreach("#{dir_path}/fnames.txt").first(options.namedepth)
    end
  else
    fnames = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
  end

  # enum the last names if we're using an option that includes full last names, otherwise return the alphabet
  if not options.fnli
    if File.exist?("#{dir_path}/lnames.txt") == false then return end
    if options.namedepth == 0
      lnames = File.foreach("#{dir_path}/lnames.txt")
    else
      lnames = File.foreach("#{dir_path}/lnames.txt").first(options.namedepth)
    end
  else
    lnames = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
  end

  # first last
  if options.filn or options.fnln or options.fnli
    fnames.each {|fname|
      lnames.each {|lname|
        data.push("#{fname.chomp}#{lname.chomp}") } }
  end

  # last first
  if options.lnfi or options.lnfn
    fnames.each {|fname|
      lnames.each {|lname|
        data.push("#{lname.chomp}#{fname.chomp}") } }
  end

  # first dot last
  if options.fidln or options.fndln
    fnames.each {|fname|
      lnames.each {|lname|
        data.push("#{fname.chomp}.#{lname.chomp}") } }
  end

  if not data.empty?
    # truncate words if specified
    if options.truncate
      data.map! {|word| word[0...options.truncate] }
    end

    # only keep maxusers number of usernames
    if options.maxusers
      data = data[0...options.maxusers]
    end

    datapp = post_processor(dir_path, options, data)

    if not options.quiet
      puts ""
      puts datapp
    end
    puts "usernames in #{dir_path}:    #{datapp.length}"
  end

end

# most of the work is done here, search a directory for flat files, bring them into memory
def get_attribute(dir_path, options, type)

  if type == "other"
    all_files = Dir.glob("#{dir_path}/**/*.txt")
    attrs = ["areacodes","cia","cities","colleges","counties","fnames","landmarks","lnames","roads","sports","zipcodes"]
    attrs.each do |attribute|
      all_files.delete_if{ |f| f.include?("#{attribute}.txt")  }
    end
  else
    all_files = Dir.glob("#{dir_path}/**/#{type}.txt")
  end

  data = []
  all_files.each do |f|
    file = File.open(f, "rb", :encoding => "ISO-8859-1:UTF-8")
    contents = ""

    # if the file has cia.txt in the name, open the file and put each word in that file on a new line
    if f.include?("cia.txt")
      cia = file.read
      contents = format_cia_demographics(cia)

    # code that we'll save for later, performance is too slow for now
    # this parsed fnames.txt files when the files were formatted like:
    # m,Bob,1239823092
    # f,Alice,834903480
    # etc.
    # since then, we've gone back to just fnames.txt
    # if getting first names, check whether we want female, male, or both
    #elsif f.include?("fnames.txt")
      # ignore sex
      #if options.fnames
      #  while line = file.gets
      #    contents += line.split(",")[1] + "\n"
      #  end
      #else
      #  while line = file.gets
      #    # female first names
      #    if options.ffnames
      #      if line.start_with?("f,")
      #        contents += line.split(",")[1] + "\n"
      #      end
      #    # male first names
      #    elsif options.mfnames
      #      if line.start_with?("m,")
      #        contents += line.split(",")[1] + "\n"
      #      end
      #    end
      #  end
      #end
    else
      contents = file.read
    end

    file.close

    data = data + contents.split("\n")
  end

  if not data.empty?
    datapp = post_processor(dir_path, options, data)

    if not options.quiet
      puts ""
      puts datapp
    end
    puts "#{type} in #{dir_path}:    #{datapp.length}"
  end
end

# open country.yaml and identify what the two most popular relgions are
def find_religion(dir_path, options)
  #yaml_file = dir_path + "/" + dir_path.split("/")[2] + ".yaml"
  yaml_file = "./data/" + dir_path.split("/")[2] + "/" + dir_path.split("/")[2]  + ".yaml"
  if File.exist?(yaml_file) == false then return end
  config = YAML.load_file(yaml_file)
	religion_1 = config["config"]["religion_1"]
  religion_2 = config["config"]["religion_2"]
  if not religion_1.nil? then @religionArr.push(religion_1.downcase) end
  if not religion_2.nil? then @religionArr.push(religion_2.downcase) end
end

# if religious text exists, import it in
def get_religion(dir_path, options)
  data = Array.new

  # this might take some explaining
  # essentially, each country.yaml file will have the two most popular religions
  # however, there are multiple "children" religions that are based off a "root" religion
  # a good example is that presbyterian's, evangelical's and orthodox's will mostly reference the KJV or DR
  # these religions.conf files act as a way to look up if the religion in a country.yaml matches a line in the religions.conf file
  # it's probably the cleanest way to do this and affords some expandability
  bible_religions = file_to_arr("./data/religion/bible-religions.conf")
  quran_religions = file_to_arr("./data/religion/quran-religions.conf")

  @religionArr.each do |religion|

    # include both the kjv and dr for any catholic and christian based religion
    if religion != nil && bible_religions.include?(religion)
      data = data + file_to_arr("./data/religion/king-james-bible-parsed.txt")
      data = data + file_to_arr("./data/religion/douay-rheims-parsed.txt")
      data = data + file_to_arr("./data/religion/new-international-version-bible-parsed.txt")
      data = data + file_to_arr("./data/religion/king-james-bible-book-verse.txt")
    end

    # include the quran for islam/muslim based religion
    if religion != nil && quran_religions.include?(religion)
      data = data + file_to_arr("./data/religion/quran-parsed-eng.txt")
    end

  end

  if not data.empty?
    datapp = post_processor(nil, options, data)

    if not options.quiet
      puts ""
      puts datapp
    end
    puts "religions:    #{datapp.length}"
  end
end

# open country.yaml and identify what the two most popular languages are
def find_language(dir_path, options)
  #yaml_file = dir_path + "/" + dir_path.split("/")[2] + ".yaml"
  yaml_file = "./data/" + dir_path.split("/")[2] + "/" + dir_path.split("/")[2]  + ".yaml"
  if File.exist?(yaml_file) == false then return end
  config = YAML.load_file(yaml_file)
	language_1 = config["config"]["language_1"]
  language_2 = config["config"]["language_2"]
  if not language_1.nil? then @languageArr.push(language_1.downcase) end
  if not language_2.nil? then @languageArr.push(language_2.downcase) end
end

# if a languages text exists, import it in
def get_language(dir_path, options)
  data = Array.new
  languages = Array.new

  # get a list of all language files
  language_list = Dir.glob("./data/languages/*.txt")

  for i in 0 .. language_list.length - 1
    # format path/language.txt to just language
    languages.push language_list[i].split("/")[3].split(".")[0].downcase
  end

  @languageArr.each do |language|

    # special dictionary for cantonese and mandarin
    if language != nil && language == "mandarin" || language == "cantonese" || language == "chinese"
      data = data + file_to_arr("./data/languages/cedict.txt")
    end

    # include the language
    if language != nil && languages.include?(language)
      data = data + file_to_arr("./data/languages/#{language}.txt")
    end

  end

  if not data.empty?
    datapp = post_processor(dir_path, options, data)

    if not options.quiet
      puts ""
      puts datapp
    end
    puts "languages:    #{datapp.length}"
  end
end

def cycle(options, dir_path)
  if options.all or options.cia then get_attribute(dir_path, options, "cia") end
  if options.all or options.cities then get_attribute(dir_path, options, "cities") end
  if options.all or options.colleges then get_attribute(dir_path, options, "colleges") end
  if options.all or options.counties then get_attribute(dir_path, options, "counties") end
  if options.all or options.landmarks then get_attribute(dir_path, options, "landmarks") end
  # code we'll save for later if we bring back male/female name separation
  #if options.all or options.fnames or options.ffnames or options.mfnames then get_attribute(dir_path, options, "fnames") end
  if options.all or options.fnames then get_attribute(dir_path, options, "fnames") end
  if options.all or options.lnames then get_attribute(dir_path, options, "lnames") end
  if options.all or options.other then get_attribute(dir_path, options, "other") end
  if options.all or options.phone then get_attribute(dir_path, options, "areacodes") end
  if options.all or options.roads then get_attribute(dir_path, options, "roads") end
  if options.all or options.sports then get_attribute(dir_path, options, "sports") end
  if options.all or options.zip then get_attribute(dir_path, options, "zipcodes") end
  if options.all or options.religion then find_religion(dir_path, options) end
  if options.all or options.language then find_language(dir_path, options) end
  if options.usergenerate then generate_users(dir_path, options) end
end

# abcdefghijklmnopqr tuvwxyz
#                   s        <-- available options
# A C EFG I  LM   R     WXYZ <-- available options
# ABCDEFGHIJKLMNOPQRSTUVWXYZ
def main()
  options = OpenStruct.new
  ARGV << '-h' if ARGV.empty?
  OptionParser.new do |opt|
    opt.banner = "Usage: ruby wordsmith.rb [options]"
    opt.on('Main Arguments:')
    opt.on('-I', '--input <input>', Array, 'Comma-delimited list of inputs, see -E for examples and detailed usage') { |o| options.input = o }
    opt.on('Input Options:')
    opt.on('-a', '--all', 'Grab all options') { |o| options.all = o }
    opt.on('-b', '--other', 'Grab other miscellaneous attributes') { |o| options.other = o }
    opt.on('-e', '--cia', 'Grab demographics compiled by the CIA') { |o| options.cia = o }
    opt.on('-c', '--cities', 'Grab all city names') { |o| options.cities = o }
    opt.on('-f', '--colleges', 'Grab all college sports') { |o| options.colleges = o }
    opt.on('-l', '--landmarks', 'Grab all landmarks') { |o| options.landmarks = o }
    opt.on('-v', '--language', 'Grab the most popular language(s)') { |o| options.language = o }
    opt.on('-N', '--all-names', 'Grab all first names and last names') { |o| options.anames = o }
    opt.on('-G', '--first-names', 'Grab all first names') { |o| options.fnames = o }
    opt.on('-L', '--last-names', 'Grab all last names') { |o| options.lnames = o }
    # saving for later usage
    #opt.on('-F', '--female-fnames', 'Grab all female first names') { |o| options.ffnames = o }
    #opt.on('-M', '--male-fnames', 'Grab all male first names') { |o| options.mfnames = o }
    opt.on('-p', '--phone', 'Grab all area codes') { |o| options.phone = o }
    opt.on('-r', '--roads', 'Grab all road names') { |o| options.roads = o }
    opt.on('-g', '--religion', 'Grab the most popular relgious text(s)') { |o| options.religion = o }
    opt.on('-t', '--teams', 'Grab all major sports teams') { |o| options.sports = o }
    opt.on('-u', '--counties', 'Grab all counties') { |o| options.counties = o }
    opt.on('-z', '--zip', 'Grab all zip codes') { |o| options.zip = o }
    opt.on('Username Generation Options:')
    opt.on('--filn', 'FirstInitialLastName (bsmith)') { |o| options.filn = o }
    opt.on('--fnln', 'FirstNameLastName (bobsmith)') { |o| options.fnln = o }
    opt.on('--fnli', 'FirstNameLastInitial (bobs)') { |o| options.fnli = o }
    opt.on('--lnfi', 'LastNameFirstInitial (smithb)') { |o| options.lnfi = o }
    opt.on('--lnfn', 'LastNameFirstName (smithbob)') { |o| options.lnfn = o }
    opt.on('--fidln', 'FirstInitial.LastName (b.smith)') { |o| options.fidln = o }
    opt.on('--fndln', 'FirstName.LastName (bob.smith)') { |o| options.fndln = o }
    # saving for later usage?
    #opt.on('--lndfi', 'LastName.FirstInitial (smith.b)') { |o| options.lndfi = o }
    #opt.on('--lndfn', 'LastName.FirstName (smith.bob)') { |o| options.lndfn = o }
    opt.on('--truncate LEN', Integer, 'Truncate username at LEN number of characters (bobsmi)') { |o| options.truncate = o }
    opt.on('--max-users LEN', Integer, 'Max number of usernames to generate') { |o| options.maxusers = o }
    opt.on('--name-depth LEN', Integer, 'Num of first/last names to iterate over (default:100, 0 will get all)') { |o| options.namedepth = o }
    # options for adding a suffix or prefix to usernames?
    opt.on('Web Scrape Options:')
    opt.on('-d', '--domain DOMAIN', 'Set a URL for a web application that you want CeWL to scrape') { |o| options.url = o }
    opt.on('-i', '--infile FILE', 'Supply a file containing multiple URLs that you want CeWL to scrape') { |o| options.multi = o }
    opt.on('Output Options:')
    opt.on('-o', '--output FILE', 'The filename for writing output') { |o| options.out = o }
    opt.on('-q', '--quiet', 'Don\'t show words generated, use with -o option') { |o| options.quiet = o }
    opt.on('-k', '--min-length LEN', Integer, 'Minimum length of word to include') { |o| options.minlength = o }
    opt.on('-n', '--max-length LEN', Integer, 'Maximum length of word to include') { |o| options.maxlength = o }
    opt.on('-D', '--complexity', 'Words must meet Windows default complexity (8 char min, 3/4 cases)') { |o| options.default = o }
    opt.on('-j', '--lowercase', 'Convert all words to lowercase') { |o| options.lower = o }
    opt.on('-w', '--specials', 'Add words with special characters removed') { |o| options.specials = o }
    opt.on('-x', '--spaces', 'Add words with spaces removed') { |o| options.spaces = o }
    opt.on('-y', '--split', 'Split words by space and add') { |o| options.split = o }
    opt.on('-m', '--mangle', 'Add all permutations (-w, -x, -y)') { |o| options.mangle = o }
    opt.on('-P', '--prepend-phones', 'Prepend state area codes to each generated word') { |o| options.prependphone = o }
    opt.on('-A', '--append-phones', 'Append state area codes to each generated word') { |o| options.appendphone = o }
    opt.on('-X', '--prepend-zips', 'Prepend zip codes to each generated word') { |o| options.prependzip = o }
    opt.on('-Z', '--append-zips', 'Append zip codes to each generated word') { |o| options.appendzip = o }
    opt.on('-W', '--prepend-wordlist FILE', 'Prepend words in FILE to each generated word') { |o| options.prependwordlist = o }
    opt.on('-Y', '--append-wordlist FILE', 'Append words in FILE to each generated word') { |o| options.appendwordlist = o }
    opt.on('Info Options:')
    opt.on('-C', '--show-child-nodes', 'Show all possible child nodes for each input') { |o| options.showchildren = o }
    opt.on('-E', '--examples', 'Show some usage examples and detailed explanations about using wordsmith') { |o| options.examples = o }
    opt.on('-R', '--show-regions', 'Show regions mapping') { |o| options.showregions = o }
  end.parse!

  if options.examples then examples() end
  if options.showregions then show_regions() end

  if options.prependwordlist
    if File.exist?(options.prependwordlist) == false
      puts "#{options.prependwordlist} does not exist! Exiting."
      exit 1
    end
  end

  if options.appendwordlist
    if File.exist?(options.appendwordlist) == false
      puts "#{options.appendwordlist} does not exist! Exiting."
      exit 1
    end
  end

  # turn on first names and last names for all names
  if options.all or options.anames
    options.fnames = true
    options.lnames = true
  end

  # turn on all manipulation switches for mangle
  if options.mangle
    options.spaces = true
    options.split = true
    options.specials = true
  end

  # if one of these flags set, then we'll generate usernames
  if options.filn or options.fnln or options.fnli or options.lnfi or options.lnfn or options.fidln or options.fndln
    options.usergenerate = true
  end

  # check options for ones that use a full first name
  if options.fnln or options.lnfn or options.fndln or options.fnli
    options.genfirstname = true
  end

  # minlength will override the default of 8
  if options.default and not options.minlength
      options.minlength = 8
  end

  # set default for name depth, meaning we'll use 100 first names and 100 last names during generation
  if not options.namedepth then options.namedepth = 100 end

  @finalArr = []
  @religionArr = []
  @languageArr = []

  # boundaries and most populous countries
  if not options.input.nil?
    # if input is a number, then use most populous country data
    if options.input.length == 1 and options.input[0].scan(/\D/).empty?
      if File.exist?('./data/most-populous-countries.csv') == false
        puts "./data/most-populous-countries.dat does not exist! Exiting."
        exit 1
      else
        populouscountries = CSV.read('./data/most-populous-countries.csv').first(options.input[0].to_i)
        puts "Grabbing data from the #{options.input[0]} most populous countries:"
        options.input.clear
        # we cleared out options.input array, replace with countries
        populouscountries.each do |country|
          puts "#{country[0]}"
          options.input.push(country[0])
        end
      end
    end

    inputs = validate_boundaries(options)
    if options.showchildren then show_children(inputs) end
    inputs.each do |i|
      cycle(options, i)
    end
    # do religions and languages as a whole at the end
    if not @religionArr.empty?
      @religionArr.sort!.uniq!
      get_religion(nil, options)
    end

    if not @languageArr.empty?
      @languageArr.sort!.uniq!
      get_language(nil, options)
    end
  end

  # web scraping
  if not options.url.nil? then scrapeSingle(options) end
  if not options.multi.nil? then scrapeMultiple(options) end

  # output
  if not options.out.nil? then output(options.out) end

end

def checkFiles()
  dataCheck = "./data/usa/az/roads.txt"
  regionsCheck = "./data/regions.csv"

  if File.exist?(dataCheck) == false || File.exist?(regionsCheck) == false
    archiveCheck = "data.tar.xz"
    if File.exist?(archiveCheck) == false
      puts "[!] data/regions.csv and data.tar.xz not detected! Try changing to the wordsmith directory."
      puts ""
      abort
    elsif File.exist?(dataCheck) == false
      puts "[*] Hello new wordsmither!"
      printf "[*] This script will remove the data/ directory in the current working directory. Enter 'y' to continue: "
      prompt = STDIN.gets.chomp
      if prompt != 'y'
        puts "[!] Aborted!"
        abort
      end
      %x[rm -rf data/]
      puts "[*] Just need to unpack some files (Running: tar -xf data.tar.xz)"
      %x[tar -xf data.tar.xz]
      puts "[*] Unpack completed!"
      cewlpath = which("cewl")
      if cewlpath.nil?
        puts "[*] WARNING: CeWL not found in path. Install CeWL and put in path to use -d or -i options."
        puts ""
      else
        puts "[*] CeWL found: #{cewlpath}"
        puts ""
      end
    else
      puts "[!] data/regions.csv not found. Try redownloading data.tar.xz from GitHub. Aborting."
      abort
    end
  end

end

title()
checkFiles()
main()
