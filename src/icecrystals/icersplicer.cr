########################################################################
#
# Author: Brian Hood
# Name: Icersplicer
#
# Description: 
#   Main module for file processing
#   
#
########################################################################
#require 'file-tail'

module Icersplicer

  class OutputFile

    def initialize
      @fileopen = 0
      @debug = 0
    end
    
    def open(outputfile)
      begin
        puts "Openfile: #{outputfile}" if @debug >= 1
        @export = File.open("#{outputfile}", "w")
      rescue 
        raise "Can't create file please check file / directory permissions"
      end
    end

    def write(data)
      @export.write(data)
    end

    def close
      begin
        @export.close
        puts "Closing file"
      rescue NoMethodError
      end
    end

    def processdata(data, outputfile, quietmode)
      open(outputfile) if @@fileopen == 0
      write(data)
      @fileopen += 1
    end
    
  end

  class FileProcessor
  
    setter nohighlighter 
    setter skip_lines
    setter keywordsfile 
    setter debug
    setter nolinenumbers
    setter home
    
    COLOURS = {"black" => 0,
               "red" => 1, 
               "green" => 2, 
               "yellow" => 3, 
               "blue" => 4,
               "purple" => 5,
               "cyan" => 6,
               "white" => 7}

    def initialize
      @keywordsfile = "keywords.ice"
      @debug = 2
      @nolinenumbers = false
      @skip_lines = Array(Int32).new
      @keys = Hash(Int32, String).new
      @home = ""
    end
    
    def reset_screen
      puts "\e[0m\ "
    end
    
    def filterlinestats(filterlines)
      puts "\nLines Displayed by Filter: #{filterlines}"
    end

    def load_keywords
      keys = Hash(Int32, String).new
      linenum = 0
      unless Dir.exists?("#{@home}")
        Dir.mkdir("#{@home}")
      end
      if File.exists?("#{@home}")
        File.open("#{@home}/#{@keywordsfile}") {|n|
          n.each_line {|l|
            keys.merge({linenum => "#{l.strip}"}) unless l.strip == ""
            puts "L: #{l.strip}" if @debug >= 1
            linenum = linenum + 1
          }
        }
        return keys
      else
        return false
      end
    end
    
    def text_processor(data)
      unless @nohighlighter == "OFF"
        data = text_highlighter(data)
        return data
      else
        return data
      end
    end

    def first_load 
      @keys = load_keywords
    end
    
    def text_highlighter(text)
      unless @keys.class == Hash
        @keys = {0 => "Ln:", 
                 1 => "SELECT", 
                 2 => "CREATE TABLE", 
                 3 => "UPDATE", 
                 4 => "DELETE", 
                 5 => "INSERT"}
      end
      cpicker = [2,3,4,1,7,5,6] # Just a selection of colours
      @keys.each {|n, x|
        if x.split("##")[1] == nil
          text.gsub!("#{x}", "\e[4;3#{cpicker[rand(cpicker.size)]}m#{x}\e[0m\ \e[0;32m")
        else
          name = x.split("##")[1].split("=")[1]; puts "Name: #{name}" if @debug >= 3
          cnum = COLOURS[name].to_i; puts "Colour Number: #{cnum}" if @debug >= 3
          nval = x.split("##")[0]; puts "Value: #{nval}" if @debug >= 3
          text.gsub!("#{nval}", "\e[4;3#{cnum}m#{nval}\e[0m\ \e[0;32m")
        end
        text.gsub!(" \e[0;32m", "\e[0;32m")
      }
      return text
    end

    def countlines(inputfile)
      lines = 0
      unless inputfile == nil
        if File.exist?(inputfile)
          File.open(inputfile) {|n|
            n.each_line {
              lines += 1
            }
          }
          puts "Filename: #{inputfile} Total Line Count: #{lines}"
        end
      end
      return lines
    end
    
    def print_to_screen(linenum, text, quiet)
      unless @nolinenumbers == true
        print "\e[1;33mLn: #{linenum}:\e[0m\ " unless quiet == true
      end
      print "#{text}" unless quiet == true
    end

    def stats(inputfile, outputfile)
      puts "Skip Lines #{@skip_lines}" if @debug >= 1
      print "Inputfile lines: "
      countlines(inputfile)
    end

  end
  
end
