require "option_parser"
require "http/client"
require "json"


# This fetches a random image from Unsplash, potentially accepting some search
# terms, and sets it as the wallpaper for a Ubuntu system.
module Wallpaper
  VERSION = "0.1.0"
  UNSPLASH_API_KEY = ENV.fetch("UNSPLASH_API_KEY", nil)
  BASE_URL = "https://api.unsplash.com/photos/random?client_id=#{UNSPLASH_API_KEY}"
  RAND = rand(100)


  OptionParser.parse do |parser|
    
    parser.on "-v", "--version", "Show version" do
      puts VERSION
      exit
    end

    parser.on "-s SEARCH_TERMS", "--search-terms=SEARCH_TERMS", "String-delimited search terms" do |search_terms|
      search_terms.split(" ").each do |term|
      end
    end
  end
  
  url = JSON.parse(HTTP::Client.get("#{BASE_URL}").body)["urls"]["full"]

  image = HTTP::Client.get(url.to_s) do |response|
    # Gnome does not refresh the background if the filename doesn't change!
    File.write("#{RAND}.jpeg", response.body_io, 0o444)
    path = File.expand_path("#{RAND}.jpeg")
    process = Process.new("gsettings",  ["set", "org.gnome.desktop.background", "picture-uri", "file://#{path}"], output: Process::Redirect::Pipe)
    if process.wait.success?
      puts "Success: set the desktop background to #{url}"
    else
      puts process.output.gets_to_end
      puts "Something went wrong."
    end

  end

end
