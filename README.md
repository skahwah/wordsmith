### wordsmith.rb 

The aim of wordsmith is to assist with creating tailored wordlists. This is mostly based on geolocation. 

#### Usage

On first run, wordsmith will unpack some files. This will take less than 5 seconds.
Alternatively you can run wordsmith.rb with the update option and download 175 MB of data from the internet.

``` shell

skawa-mbp:wordsmith $ ruby wordsmith.rb -h
wordsmith v1.0
Written by: Sanjiv "Trashcan Head" Kawa & Tom "Pain Train" Porter
Twitter: @skawasec & @porterhau5

Hello new wordsmither! Just need to unpack some files.

Unpack completed!

Usage: ruby wordsmith.rb [options]
Main Arguments:
    -s, --state STATE                The US state set for the program
State Options:
    -a, --all                        Grab everything for the specified state
    -c, --cities                     Grab all city names for the specified state
    -l, --landmarks                  Grab all landmarks for the specified state
    -p, --phone                      Grab all area codes for the specified state
    -r, --roads                      Grab all road names in the specified state
    -t, --teams                      Grab all major sports teams in the specified state
    -z, --zip                        Grab all zip codes for the specified state
Miscellaneous Options:
    -d, --domain DOMAIN              Set a URL for a web application that you want CeWL to scrape
    -e, --examples                   Show some usage examples
    -i, --infile FILE                Supply a file containing multiple URLs for web applications that you want CeWL to scrape
    -n, --names                      Grab the most common male, female, baby and last names in the USA
    -o, --output FILE                The name of the output file
    -q, --quiet                      Don't show words generated, use with -o option
Management:
    -u, --update                     Update the program
    -f, --force                      Forcefully update the program
skawa-mbp:wordsmith $ 
```

#### Command Examples
```
Grab all of the cities and towns for California
    ruby wordsmith.rb -s CA -c

Grab everything for California, write to file named california.txt
    ruby wordsmith.rb -s CA -a -o california.txt

Grab everything for California and run CeWL against https://www.popped.io
    ruby wordsmith.rb -s CA -a -d https://www.popped.io

Create a mega wordlist containing all states with all options, quiet output
    ruby wordsmith.rb -s all -q -o wordsmith-all.txt

Grab the most common male, female, baby and last names in the USA
    ruby wordsmith.rb -n
```
