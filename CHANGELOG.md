# Change Log
All notable changes to this project will be documented in this file.

## [2.0.8] - 2018-01-10
### Added
 - USA geonames (1,828,312 new words)
   - Water/Island features: harbors, channels, lakes, beaches, canals, streams, etc. (--waters)
   - Man-made structures: schools, churches, hospitals, airports, bridges, buildings, etc. (--structures)
   - Land features: forests, parks, trails, plains, ridges, etc. (--lands)
   - Populated places: locales, towns, villages, settlements, census designated places, etc. (--places)
   - Full list of features included here: https://geonames.usgs.gov/apex/f?p=gnispq:8:0:::::

### Fixed
 - "religious" typo


## [2.0.7] - 2017-10-11
### Added
 - specify N most populous countries as input (ex: -I 10)
 - added landmarks and archeological sites to 110 countries
 - maximum length option (-n, --max-length)
 - username generation options (--filn, --fnln, --fnli, --lnfi, --lnfn, --fidln, --fndln, --truncate, --max-users, --name-depth)

### Changed
 - length option to minimum length (--length to --min-length)
 - moved religion/language parsing from each boundary to a bulk import at end of processing

### Fixed
 - fixed YAML config files for ata,bvt,hmd,iot,sgs,sjm
 - sort and uniq order, would fail when using -o option
 - sort for child node results (-C)


## [2.0.6] - 2017-09-18
### Added
 - cia option (-e)
 - prepend/append user-supplied wordlist (-W, -Y)
 - usa and usa state first names, usa last names

### Changed
 - *-cia.txt to cia.txt
 - skawasec to hackerjiv in README


## [2.0.5] - 2017-09-05
### Added
 - changed data compression type to xz, which uses the same compression algorithm as 7zip (LZMA2). Reduced data archive size from 56M to 43M


## [2.0.4] - 2017-09-05
### Added
 - languages completed with licenses.
 - data.tar.bz changed to data.tar.bz2


## [2.0.3] - 2017-09-05
### Added
 - religions should be complete
 - added languages into data.tar.bz
 - reorganized structure so regions, languages, etc are all in data.tar.bz
 - get_language(dir_path, options)
 - refactored the way files are brought into arrays via file_to_arr(f)
 - added comments to code


## [2.0.2] - 2017-08-29
### Added
 - get_religion(dir_path) - currently working on a way to include religions


## [2.0.1] - 2017-08-28
### Added
 - yaml files into each countries data directory
 - cia demographic files into each countries data directory
 - format_cia_demographics(contents)

### Changed
 - data.tar.bz instead of gz. bz reduced size from 49.4 MB to 46.2 MB
 - data directory included yaml and cia files (compressed in data.tar.gz)
 - get_attribute(dir_path, options, type) view comments in code
 - unpack data.tar.gz to data.tar.bz
 - sanjiv's twitter handle

### Removed
 - color output (red, blue, gray)


## [2.0] - 2016-09-10
### Added
 - regions.csv file for managing user-defined regions
 - show regions option (-R)
 - show child nodes option (-C)
 - counties attribute (-u)
 - grab all other .txt files that don't have an option (-b)
 - OpenStreetMap license

### Changed
 - data directory (compressed in data.tar.gz)
   - structure follows format: data/3-letter ISO country code/nested administrative regions. Example: data/usa/ca
     - administrative region may be state (USA), province (Canada), NUTS region (Italy), County (GBR-England), etc.
   - data from OpenStreetMap for roads, cities, and counties:
     - 249 countries
     - 32 counties in England
     - 27 sub-regions of France
     - 16 sub-regions of Germany
     - 16 sub-regions of Poland
     - 5 sub-regions of Italy
   - data from US Census
     - Puerto Rico, USA (usa-pr) with cities and counties
     - updated cities.txt for all USA states
     - added counties.txt for all USA states
 - show examples and detailed usage option (was -e, now -E)
 - input option (was -s, now -I)

### Removed
 - update option (-u)
 - sources.yml file


## [1.1] - 2016-08-08
### Added
 - append/prepend zip codes and area codes

### Fixed
 - chomp zip codes
 - UTF-8 encoding


## [1.0] - 2016-07-06
initial release
