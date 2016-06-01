########################################################################
#
# Author: Brian Hood
# Name: Icecrystals
# Email: brianh6854@googlemail.com
# Github: https://github.com/puppetpies/icecrystals
#
# Description: 
#  Optimized version of icersplicer in Crystal
#
# Why: for processing large datasets quickly.
#
# Example: icersplicer -f /data2/threatmonitor.sql -k keywords-ruby.ice -g '44551'
#
########################################################################

require "option_parser"
require "../src/icecrystals"

include GlobUtils 
include Icersplicer

class FileError < Exception; end

home = "#{ENV["HOME"]}/.icersplicer"
puts "Home: #{home}"
file = "keywords.ice"
VERSION = Icersplicer::VERSION::STRING

ice = FileProcessor.new
ice.home = home
ice.highlighter = "ON"

lineoffset = 0
linelimit = 0
increment_offset = 0
increment_limit = 1
linecounter = 0
quietmode = false
skipblank = false
grep = "" # Blank as default
nostats = "NO"

inputfile = ""
outputfilename = "DISABLED"
filenames = ""
search_and_replace = false

is_debug = false

def print_stamp
  puts "Author: Brian Hood"
  puts "Homepage: https://github.com/puppetpies/icecrystals"
end

def option_nameval(var, text)
  puts "#{var}: #{text}"
end

oparse = OptionParser.parse! do |parser|
  parser.banner = "Usage: icecrystals #{VERSION} [options]"

  parser.on("-f INTPUTFILE", "--inputfile=INPUTFILE", "\tInput filename") {|f|
    inputfile = f
    option_nameval("Filename", f)
  }

  parser.on("-k keywords.ice", "--keywordsfile=KEYWORDSFILE", "\tKeywords / Syntax Hightlighting") {|k|
    ice.keywordsfile = k
    option_nameval("Keywords", k)
  }
  
  parser.on("-g STRING", "--grep=STRING", "Filter string") {|g|
    grep = g
    option_nameval("Grep", g)
  }
  
  parser.on("-l INT", "--lineoffset=INT", "Offset from the beginning of the file") {|l|
    lineoffset = l.to_i
  }

  parser.on("-3 INT", "--head=INT", "From beginning of file number of lines display able") {|l|
    linelimit = l.to_i
    option_nameval("Head / Line Limit", l)
  }

  parser.on("-4 INT", "--tail=INT", "lines display able at the end of the file") {|l|
    count = ice.countlines(inputfile)
    lineoffset = count - l.to_i
    option_nameval("Tail / Line Limit", l)
  }

  parser.on("-c", "--countlines", "Counts the lines of a file") {|c|
    unless inputfile == ""
      countlines = ice.stats(inputfile, outputfilename)
      exit
    end
  }
  
  parser.on("-s INT", "--skiplines=INT", "Line numbers / sequences 3,4,5-10,12") {|s|
    ice.skip_lines = ice.skip_processor(s)
    option_nameval("Skiplines", s)
  }
  
  parser.on("-b", "--skipblank", "Ommit blank lines") {|b|
    skipblank = true
  }
  
  parser.on("-t", "--nohighlighter", "Turn off highlighter") {|t|
    ice.highlighter = "OFF"
  }

  parser.on("-6", "--nostats", "Don't process statistics before exit") {
    nostats = "SKIP"
  }
  
  parser.on("-7", "--nolinenumbers", "No Line numbers") {|l|
    ice.nolinenumbers = true
  }
  
  parser.on("-o OUTPUTFILE", "--outputfile", "Outputfile") {|o|
    outputfilename = o
  }

  parser.on("-q", "--quiet", "Quiet") {|q|
    quietmode = true
  }

  parser.on("-h", "--help", "Show this help") {|h|
    puts parser
    puts
    print_stamp
    exit 0
  }
  
  parser.unknown_args {|u|
    begin
      inputfile = u[0] unless inputfile.size > 0
    rescue
      puts "Take a look at the help -h\n"
      puts "Please specify inputfile exiting..."
      exit
    end
  }

end
oparse.parse!

ice.first_load
tm = Icersplicer::Timers.new; tm.start;
filterlines = 0
#begin
  # Regular file / glob mask processor
#  begin
    #filenames = joinfilenames(buildfilelist(inputfile))
    #pp filenames
    # Iterator for file / file list
    #filenames.split(",").each {|f|
    #  linecounter = 0
    #  ice.reset_screen
    #   puts "> Filename: #{f} <"
        File.open(inputfile) {|n|
          n.each_line {|data|
            data_orig = data.clone
            #if search_and_replace == true
            #  data.gsub!("#{search}", "#{replace}")
            #end
            unless lineoffset > increment_offset
              unless linelimit == 0
                unless increment_limit > linelimit
                  unless skipblank && data_orig.strip == ""
                    if data_orig =~ /#{grep}/
                      filterlines += 1
                      ice.print_to_screen(linecounter, ice.text_processor(data), quietmode) unless ice.skip(linecounter)
                      unless outputfilename == "DISABLED"
                        #data_orig.gsub!("#{search}", "#{replace}")
                        output = Icersplicer::OutputFile.new
                        output.outputfilename = outputfilename
                        output.write(data_orig) unless ice.skip(linecounter)
                      end
                    end
                  end
                end
              else
                unless skipblank && data_orig.strip == ""
                  if data_orig =~ /#{grep}/
                    filterlines += 1
                    ice.print_to_screen(linecounter, ice.text_processor(data), quietmode) unless ice.skip(linecounter)
                    unless outputfilename == "DISABLED"
                      #data_orig.gsub!("#{search}", "#{replace}")
                      output = Icersplicer::OutputFile.new
                      output.outputfilename = outputfilename
                      output.write(data_orig) unless ice.skip(linecounter)
                    end
                  end
                end
              end
              increment_limit = increment_limit + 1
            end
            increment_offset = increment_offset + 1
            linecounter = linecounter + 1
          }
        }
      #}
#  rescue 
#    raise "Please specify a valid filename or wildcard file extension"
#  end
#rescue 
#  raise "Closing session due to broken pipe"
#end
#ice.close
#unless instance_variable_defined?("@nostats")
#  ice.filterlinestats(filterlines)
#  ice.stats(inputfile, outputfile)
#  timer.watch('stop')
#  timer.print_stats
#
unless nostats == "SKIP"
  ice.stats(inputfile, outputfilename)
  tm.stop
  duration = tm.stats
  puts "\nLines Displayed by Filter: #{filterlines}"
  puts duration
end
ice.reset_screen
