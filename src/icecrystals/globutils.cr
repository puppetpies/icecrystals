
module GlobUtils

  FILE_EXT_REGEXP = /\/*.([a-z]|[A-Z])+$/
  FILE_WILDCARD_REGEXP = /\*.([a-z]|[A-Z])+$/
  @@debug = 0

  def glob(f)
    puts "String end: #{f[f.size - 1]}" if @@debug == 1
    unless f[f.size - 1] == "*"
      files = Hash(String, String).new(0)
      globcounter = 0
      fileext = f.split(".")[f.split(".").size - 1] # Extract Extension from string for example .rb
      fileglob = f.gsub(FILE_EXT_REGEXP, "/**/*.#{fileext}").gsub("/*/", "/") # Match to find anything file extension / replace Glob using fileext
      begin
        # Send created glob into Dir.glob
        Dir.glob(fileglob) {|n|
          files.merge({globcounter => n})
          globcounter += 1
        }
      rescue 
        raise "Invalid Glob" 
      end
      return files
    else
      raise "Please specify file extension for glob i.e *.html"
    end
  end

  def joinfilenames(rollfiles)
    filenames = ""
    rollfiles.each {|n|
      filenames = "#{filenames},#{n[1]},"
      puts filenames
    }
    filenames.gsub(/,$/, "")
  end
  
  def buildfilelist(inputfile)
    rollfiles = Hash(String, String).new(0)
    rollcounter = 0
    inputfile.split(",").each {|f|
      puts "Filename: #{f}" if @@debug == 1
      unless f =~ FILE_WILDCARD_REGEXP
        rollfiles.merge({rollcounter => f})
        rollcounter += 1
        puts "Regular File" if @@debug == 1
      else
        puts "Glob File Mask" if @@debug == 1
        g = glob(f)
        g.each {|n|
          rollfiles.update({rollcounter => n[1]})
          rollcounter += 1
        }
      end
    }
    return rollfiles
  end

end
