# icecrystals - Experimental

Icecrystals - Icersplicer written in Crystal for performance benefits of compiled code.

There is a more extensive Ruby version @ http://github.com/puppetpies/icersplicer

## Installation

You need Crystal 0.11 / 0.12 installed

You can build icecrystals with

````
make
make install
````

## Usage

````
Home: /home/brian/.icersplicer
Usage: icecrystals [options]
    -f INTPUTFILE, --inputfile=INPUTFILE	Input filename
    -k keywords.ice, --keywordsfile=KEYWORDSFILE	Keywords / Syntax Hightlighting
    -g STRING, --grep=STRING         Filter string
    -l INT, --lineoffset=INT         Offset from the beginning of the file
    -3 INT, --head=INT               From beginning of file number of lines display able
    -4 INT, --tail=INT               lines display able at the end of the file
    -s INT, --skiplines=INT          Line numbers / sequences 3,4,5-10,12
    -t, --nohighlighter              Turn off highlighter
    -o OUTPUTFILE, --outputfile      Outputfile
    -q, --quiet                      Quiet
    -h, --help                       Show this help

Author: Brian Hood
Homepage: https://github.com/puppetpies/icecrystals
````

## Development

````
TODO: Implement Icersplicer common functions.

skipblank
syntax highlighting
````

## Contributing

1. Fork it ( https://github.com/puppetpies/icecrystals/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [puppetpies]](https://github.com/puppetpies) Bri in The Sky - creator, maintainer

# icecrystals
