### wordsmith.rb 

The aim of wordsmith is to assist with creating tailored wordlists. This is mostly based on geolocation. 

#### Usage

On first run, wordsmith will unpack some files. This will take less than 5 seconds.
Alternatively you can run wordsmith.rb with the update option and download 175 MB of data from the internet.

``` shell

skawa-mbp:wordsmith $ ruby wordsmith.rb -h
wordsmith v1.0
Written by: Sanjiv Kawa & Tom Porter
Twitter: @skawasec & @porterhau5

Usage: ruby wordsmith.rb [options]
Main Arguments:
    -s, --state STATE                The US state set for the program
Options:
    -a, --all                        Grab everything for the specified state
    -c, --cities                     Grab all of the cities and towns for the specified state
    -d, --domain DOMAIN              Set a URL for a web application that you want CeWL to scrape
    -e, --examples                   Show some usage examples
    -i, --infile FILE                Supply a file containing multiple URLs for web applications that you want CeWL to scrape
    -l, --landmarks                  Grab all of the landmarks for the specified state
    -n, --names                      Grab the most common male, female, baby and last names in the USA
    -o, --output FILE                The name of the output file
    -p, --phone                      Grab all of the area codes for the specified state
    -r, --roads                      Grab all of the street and road names in the specified state
    -t, --teams                      Grab all of the major sports teams in the specified state
    -z, --zip                        Grab the zip codes for the specified state
Management:
    -u, --update                     Update the program
    -f, --force                      Forcefully update the program
skawa-mbp:wordsmith $ 
```

#### Command Examples
```
ruby wordsmith.rb -s CA -a -o california.txt 		- This will grab everything for California and save it to an outfile


ruby wordsmith.rb -s CA -c 				- This will grab all of the cities and towns for California


ruby wordsmith.rb -n 					- This will grab the most common male, female, baby and last names in the USA


ruby wordsmith.rb -s CA -a -d https://ww.popped.io 	- This will grab everything for California and run CeWl against the specified domain
```
