### wordsmith.rb

The aim of Wordsmith is to assist with creating tailored wordlists and usernames that are primarilly based on geolocation. 

authors: [@hackerjiv](https://twitter.com/hackerjiv) & [@porterhau5](https://twitter.com/porterhau5)

#### Installation

On first run, Wordsmith will unpack some files from data.tar.xz. This may take a few seconds.

``` shell
$ git clone https://github.com/skahwah/wordsmith.git
Cloning into 'wordsmith'...
remote: Counting objects: 651, done.
remote: Compressing objects: 100% (23/23), done.
Receiving objects: 100% (651/651), 166.45 MiB | 2.20 MiB/s, done.
Resolving deltas: 100% (337/337), done.

$ cd wordsmith
$ ruby wordsmith.rb
wordsmith v2.0.7
Written by: Sanjiv "Trashcan Head" Kawa & Tom "Pain Train" Porter
Twitter: @hackerjiv & @porterhau5

[*] Hello new wordsmither!
[*] This script will remove the data/ directory in the current working directory. Enter 'y' to continue: y
[*] Just need to unpack some files (Running: tar -xf data.tar.xz)
[*] Unpack completed!
[*] CeWL found: /usr/bin/cewl
```

#### Usage

``` shell
$ ruby wordsmith.rb
wordsmith v2.0.7
Written by: Sanjiv "Trashcan Head" Kawa & Tom "Pain Train" Porter
Twitter: @hackerjiv & @porterhau5

Usage: ruby wordsmith.rb [options]
Main Arguments:
    -I, --input <input>              Comma-delimited list of inputs, see -E for examples and detailed usage
Input Options:
    -a, --all                        Grab all options
    -b, --other                      Grab other miscellaneous attributes
    -e, --cia                        Grab demographics compiled by the CIA
    -c, --cities                     Grab all city names
    -f, --colleges                   Grab all college sports
    -l, --landmarks                  Grab all landmarks
    -v, --language                   Grab the most popular language(s)
    -N, --all-names                  Grab all first names and last names
    -G, --first-names                Grab all first names
    -L, --last-names                 Grab all last names
    -p, --phone                      Grab all area codes
    -r, --roads                      Grab all road names
    -g, --religion                   Grab the most popular relgious text(s)
    -t, --teams                      Grab all major sports teams
    -u, --counties                   Grab all counties
    -z, --zip                        Grab all zip codes
Username Generation Options:
        --filn                       FirstInitialLastName (bsmith)
        --fnln                       FirstNameLastName (bobsmith)
        --fnli                       FirstNameLastInitial (bobs)
        --lnfi                       LastNameFirstInitial (smithb)
        --lnfn                       LastNameFirstName (smithbob)
        --fidln                      FirstInitial.LastName (b.smith)
        --fndln                      FirstName.LastName (bob.smith)
        --truncate LEN               Truncate username at LEN number of characters (bobsmi)
        --max-users LEN              Max number of usernames to generate
        --name-depth LEN             Num of first/last names to iterate over (default:100, 0 will get all)
Web Scrape Options:
    -d, --domain DOMAIN              Set a URL for a web application that you want CeWL to scrape
    -i, --infile FILE                Supply a file containing multiple URLs that you want CeWL to scrape
Output Options:
    -o, --output FILE                The filename for writing output
    -q, --quiet                      Don't show words generated, use with -o option
    -k, --min-length LEN             Minimum length of word to include
    -n, --max-length LEN             Maximum length of word to include
    -D, --complexity                 Words must meet Windows default complexity (8 char min, 3/4 cases)
    -j, --lowercase                  Convert all words to lowercase
    -w, --specials                   Add words with special characters removed
    -x, --spaces                     Add words with spaces removed
    -y, --split                      Split words by space and add
    -m, --mangle                     Add all permutations (-w, -x, -y)
    -P, --prepend-phones             Prepend state area codes to each generated word
    -A, --append-phones              Append state area codes to each generated word
    -X, --prepend-zips               Prepend zip codes to each generated word
    -Z, --append-zips                Append zip codes to each generated word
    -W, --prepend-wordlist FILE      Prepend words in FILE to each generated word
    -Y, --append-wordlist FILE       Append words in FILE to each generated word
Info Options:
    -C, --show-child-nodes           Show all possible child nodes for each input
    -E, --examples                   Show some usage examples and detailed explanations about using wordsmith
    -R, --show-regions               Show regions mapping
```

#### Command Examples
```
$ ruby wordsmith.rb -E
wordsmith v2.0.7
Written by: Sanjiv "Trashcan Head" Kawa & Tom "Pain Train" Porter
Twitter: @hackerjiv & @porterhau5

Input names:
------------
Valid inputs for wordsmith (using -I option) are based on nodes located in the "data" directory.
The top-level nodes are countries labeled by their 3-letter ISO Country Code:
    data/gbr : Great Britain
    data/usa : United States
    data/deu : Germany
    etc.

Some countries are divided into states, provinces, counties, or municipalities. These child nodes
are nested beneath the parent:
    data/can/on : Ontario, Canada
    data/usa/nc/raleigh : Raleigh, NC, USA
    data/gbr/eng/sx/east_sussex : East Sussex, Sussex, England, Great Britain

Inputs for wordsmith use these node paths, but with a hyphen (-) delimiter:
    ruby wordsmith.rb -I gbr [options]
    ruby wordsmith.rb -I can-on [options]
    ruby wordsmith.rb -I usa-nc-raleigh [options]

If you prefer to not dig through the "data" directory looking for potential inputs or attributes,
use -C to show children nodes for a given input:
    ruby wordsmith.rb -I all -C         (show all potential nodes)
    ruby wordsmith.rb -I usa -C         (show children nodes of USA)
    ruby wordsmith.rb -I gbr-eng -C     (show children nodes of England)

Alternatively, inputs can also be user-defined through the use of the "regions.csv" file. Wordsmith
ships with a few regions already defined, such as:
    Continents    : africa, asia, europe, etc.
    US regions    : southeast, newengland, greatlakes, etc.
    Unions/Assoc. : eu, asean, nafta, etc.

These region aliases can be found by inspecting "regions.csv" or by using the -R option:
    ruby wordsmith.rb -R

Attributes:
-----------
Each node may have one or more attributes, such as cities, roads, colleges, etc. Wordsmith will recurse
every child node and grab data for the specified attribute. For example, the following syntax starts at
the top-level "usa" node and recurses into every sub-directory looking for zip codes:
    ruby wordsmith.rb -I usa -z

Some attributes are widely-used, such as roads (-r), cities (-c), and a handful of others. Use the -h
option to see a listing of those attributes. Some attributes may be unique to an area and don't have a
dedicated option. These can still be grabbed by using the -b option. The -b option will look for all
txt files that are not one of attributes with a dedicated option. For example, if someone generated data
for all of the lakes in Minnesota and placed it in "data/usa/mn/lakes.txt", this can be grabbed using:
    ruby wordsmith.rb -I usa-mn -b

Extending wordsmith to incorporate new data is as simple as creating a ".txt" file in the proper data
directory. If you have data that you'd think would benefit other users, please connect with us on GitHub.

Basic usage:
------------
Show all children nodes and attributes for Great Britain
    ruby wordsmith.rb -I gbr -C

Grab all of the most popular names for USA
    ruby wordsmith.rb -I usa -n

Grab all of the zip codes for California
    ruby wordsmith.rb -I usa-ca -z

Grab all of the sports teams for Charlotte, NC, USA
    ruby wordsmith.rb -I usa-nc-charlotte -t -m

Grab all of the landmarks for California, Montana, and Florida
    ruby wordsmith.rb -I usa-ca,usa-mt,usa-fl -l


Using regions:
--------------
Show regions defined in regions.csv
    ruby wordsmith.rb -R

Grab all of the cities for the European Union
    ruby wordsmith.rb -I eu -c

Grab all of the roads for New England (U.S.)
    ruby wordsmith.rb -I newengland -r


Username generation:
--------------------
Generate usernames with format FirstinitialLastName:
    ruby wordsmith.rb -I usa --filn

Generate usernames with format LastnameFirstname, truncate usernames to 8 characters:
    ruby wordsmith.rb -I usa --lnfn --truncate 8

Generate usernames with format Firstname.LastName using the 250 most popular first and last names
    ruby wordsmith.rb -I usa --fndln --name-depth 250


Output formatting:
------------------
Grab all colleges for California, mangle the output, convert to lowercase
    ruby wordsmith.rb -I usa-ca -f -m -j

Grab all roads for England with a minimum character length of 8
    ruby wordsmith.rb -I gbr-eng -r -k 8

Grab everything for Italy, write to file named italy.txt
    ruby wordsmith.rb -I ita -a -o italy.txt

Create a mega wordlist containing all countries with all options, quiet output, write to file named all.txt
    ruby wordsmith.rb -I all -m -q -o all.txt


Web scraping:
-------------
Run CeWL against https://www.popped.io, mangle the output
    ruby wordsmith.rb -d https://www.popped.io -m

Run CeWL against list of URLs contained in urls.txt, write to file out.txt
    ruby wordsmith.rb -i urls.txt -m -o out.txt
```

#### Dependencies
Wordsmith should work without any external gems, with the exception of the CeWL integration options (`-d`, `-i`). These features are completely optional and can be ignored if not using them. A Gemfile has been included to simplify gem installation for CeWL. These can be installed using `bundle install`. Alternatively, each gem can be installed manually using `gem install <gem>`. Wordsmith assumes the CeWL executable (cewl) is on the user's PATH. If cewl is not found, Wordsmith will skip the URLs and continue. Instructions for installing CeWL can be found in Robin Wood's CeWL repository: https://github.com/digininja/CeWL

Wordsmith uses data that's been compressed in data.tar.xz. On first run, Wordsmith will unpack this to a directory called "data/" in the current working directory. This can be circumvented manually using `tar -xf data.tar.xz`.

BSidesDC 2017 Presentation - The world is y0ur$: Geolocation-based wordlist generation with wordsmith: https://www.slideshare.net/SanjivKawa/the-world-is-y0ur-geolocationbased-wordlist-generation-with-wordsmith-80562011
