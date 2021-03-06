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
    
    property? debug : Int32
    property? outputfilename : String
    setter outputfilename
    
    def initialize
      @debug = 0
      @outputfilename = ""
    end
    
    def write(data)
      begin
        puts "Openfile: #{@outputfilename}" if @debug >= 1
        File.open("#{@outputfilename}", "a") {|n|
          n.print(data)
        }
      rescue 
        raise "Can't create file please check file / directory permissions"
      end 
    end
    
  end

  class Timers
    
    property? start : Time
    property? finish : Time
    
    def initialize
      @start = Time.now
      @finish = Time.now
    end
    
    def start
      @start = Time.now
    end
    
    def stop
      @finish = Time.now
    end
    
    def stats : String
      duration = @finish - @start
      return "Start: #{@start} Finish: #{@finish} Duration: #{duration.to_s}"
    end
    
  end
  
  class FileProcessor
  
    property? highlighter : String
    property? keywordsfile : String
    property? debug : Int32
    property? nolinenumbers : Bool
    property? home : String
    
    setter highlighter 
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

    KEYWORD_DELIMITER = ","
    
    def initialize
      @highlighter = "OFF"
      @keywordsfile = "keywords.ice"
      @debug = 0
      @nolinenumbers = false
      @skip_lines = Hash(Int32, Int32).new
      @keys = Hash(Int32, String).new
      @home = ""
    end

    def skip_processor(filter) : Hash
      skip_lines = Hash(Int32, Int32).new
      skipcounter, comb = 0, 0
      puts "Filter: #{filter}"
      filter.to_s.split(",").each {|n|
        if n.split("-").size == 2
          min = n.split("-")[0].to_i
          max = n.split("-")[1].to_i
          min.upto(max) {|u|
            skip_lines.merge!({comb => u.to_i})
            comb = comb + 1
            puts "Comb: #{comb} U: #{u.to_i}" if @debug == 3
          }
        else
          skip_lines.merge!({comb => n.to_i})
          comb = comb + 1
          puts "Comb: #{comb} U: #{n.to_i}" if @debug == 3
        end
      }
      return skip_lines
    end
  
    def skip(line) : Bool | Nil
      begin
        line_element = @skip_lines.key(line)
        puts "Line Element: #{line_element}" if @debug == 3
        if line_element != nil
          skiper = true
          return true
        else
          skiper = nil
        end
      rescue KeyError
        puts "Invalid Hash Key" if @debug == 3
      end
      return skiper
    end

    def reset_screen : Nil
      puts "\e[0m\ "
    end
    
    def filterlinestats(filterlines) : Nil
      puts "\nLines Displayed by Filter: #{filterlines}"
    end

    def load_keywords : Hash
      keys = Hash(Int32, String).new
      linenum = 0
      unless Dir.exists?("#{@home}")
        Dir.mkdir("#{@home}")
      end
      if File.exists?("#{@home}/#{@keywordsfile}")
        puts "File Exists" if @debug >= 2
        File.open("#{@home}/#{@keywordsfile}") {|n|
          n.each_line {|l|
            keys.merge!({linenum => "#{l.strip}"}) unless l.strip == ""
            puts "Ln: #{linenum} L: #{l.strip}" if @debug >= 2
            linenum = linenum + 1
          }
        }
        return keys
      else
        return Hash(Int32, String).new
      end
    end
    
    def text_processor(data) : String
      unless @highlighter == "OFF"
        data = text_highlighter(data)
        return data
      else
        return data
      end
    end

    def first_load : Hash
      @keys = load_keywords
    end
    
    def text_highlighter(text) : String
      cpicker = [2,3,4,1,7,5,6] # Just a selection of colours
      @keys.each {|n, x|
        if x.split(KEYWORD_DELIMITER)[1] == nil
          begin
            text = text.gsub("#{x}", "\e[4;3#{cpicker[rand(cpicker.size)]}m#{x}\e[0m\ \e[0;32m")
          rescue
            raise "Error in random #{x}"
          end
        else
          begin
            name = x.split(KEYWORD_DELIMITER)[1].split("=")[1]; puts "Name: #{name}" if @debug == 3
            cnum = COLOURS[name].to_i; puts "Colour Number: #{cnum}" if @debug == 3
            nval = x.split(KEYWORD_DELIMITER)[0]; puts "Value: #{nval}" if @debug == 3
            text = text.gsub("#{nval}", "\e[4;3#{cnum}m#{nval}\e[0m\ \e[0;32m")
          rescue
            raise "Error in numbered colour Name: #{name} Number: #{cnum}"
          end
        end
        text = text.gsub(" \e[0;32m", "\e[0;32m")
      }
      return text
    end

    def countlines(inputfile) : Number
      lines = 0
      unless inputfile == nil
        if File.exists?(inputfile)
          File.open(inputfile) {|n|
            lines = n.each_line.size
          }
          puts "Filename: #{inputfile} Total Line Count: #{lines}"
        end
      end
      return lines
    end
    
    def print_to_screen(linenum, text, quiet) : Nil
      unless @nolinenumbers == true
        print "\e[1;33mLn: #{linenum}:\e[0m\ " unless quiet == true
      end
      print "#{text}" unless quiet == true
    end

    def stats(inputfile, outputfile) : Number
      puts "Skip Lines #{@skip_lines}" if @debug >= 1
      print "\nInputfile lines: "
      countlines(inputfile)
    end

  end
  
end
