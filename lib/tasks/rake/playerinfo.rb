require 'rubygems'
require 'uri'
require 'net/http'
require 'open-uri'
require 'hpricot'
require 'csv'
require 'timeout'
require 'fileutils'

class RosterUrls
  
  attr_reader :teams 
  DOMAIN = "http://mlb.mlb.com"
  PLAYER_PATH = "/mlb/players/?tcid=nav_mlb_players"
  
  @@team_city_list = [  { :team => "Orioles", :city => "Baltimore", :key => "baltimore.orioles" },
                        { :team => "Red Sox", :city => "Boston", :key => "boston.redsox" },
                        { :team => "Yankees", :city => "New York", :key => "newyork.yankees" },
                        { :team => "Rays", :city => "Tampa Bay", :key => "tampabay.rays" },
                        { :team => "Blue Jays", :city => "Toronto", :key => "toronto.bluejays" },
                        { :team => "White Sox", :city => "Chicago", :key => "chicago.whitesox" },
                        { :team => "Indians", :city => "Cleveland", :key => "cleveland.indians" },
                        { :team => "Tigers", :city => "Detroit", :key => "detroit.tigers" }, 
                        { :team => "Royals", :city => "Kansas City", :key => "kansascity.royals" },
                        { :team => "Twins", :city => "Minnesota", :key => "minnesota.twins" },
                        { :team => "Angels", :city => "Los Angeles", :key => "losangeles.angels" },
                        { :team => "Athletics", :city => "Oakland", :key => "oakland.athletics" },
                        { :team => "Mariners", :city => "Seattle", :key => "seattle.mariners" },
                        { :team => "Rangers", :city => "Texas", :key => "texas.rangers" },
                        { :team => "Braves", :city => "Atlanta", :key => "atlanta.braves" },
                        { :team => "Marlins", :city => "Florida", :key => "florida.marlins" }, 
                        { :team => "Mets", :city => "New York", :key => "newyork.mets" }, 
                        { :team => "Phillies", :city => "Philadelphia", :key => "philadelphia.phillies" },
                        { :team => "Nationals", :city => "Washington", :key => "washington.nationals" },
                        { :team => "Cubs", :city => "Chicago", :key => "chicago.cubs" },
                        { :team => "Reds", :city => "Cincinnati", :key => "cincinnati.reds" },
                        { :team => "Astros", :city => "Houston", :key => "houston.astros" },
                        { :team => "Brewers", :city => "Milwaukee", :key => "milwaukee.brewers" },
                        { :team => "Pirates", :city => "Pittsburgh", :key => "pittsburgh.pirates" }, 
                        { :team => "Cardinals", :city => "St. Louis", :key => "stlouis.cardinals" },
                        { :team => "Diamondbacks", :city => "Arizona", :key => "arizona.diamondbacks" },
                        { :team => "Rockies", :city => "Colorado", :key => "colorado.rockies" },
                        { :team => "Dodgers", :city => "Los Angeles", :key => "losangeles.dodgers" },
                        { :team => "Padres", :city => "San Diego", :key => "sandiego.padres" }, 
                        { :team => "Giants", :city => "San Francisco", :key => "sanfrancisco.giants" } ]
  
  def initialize
    @domain = "http://mlb.mlb.com"
    @playerPath = "mlb/players/?tcid=nav_mlb_players"
    html = getHtml("#{DOMAIN}#{PLAYER_PATH}")
    return false if html.nil?
    @teams = parseHtml(html)
  end
  
  def getHtml(url)
    begin
      Timeout::timeout(30) do
        p "Fetching #{url}"
        doc = open(url) do |f| 
          return Hpricot(f) 
        end
      end
    rescue Timeout::Error
      p "Error: Page Timeout - #{url}"
      return nil
    end
  end
  
  def parseHtml(html)
    hsh = {}
    html.search("//select[@id='ps_team']/option") do |url|
      team_url = url.get_attribute("value").to_s.strip
      hsh[url.inner_html] = team_url unless team_url.empty?
    end
    hsh
  end
  
end

class Team < RosterUrls
  
  attr_reader :team, :url, :roster
  POSITIONS = ["Pitchers","Catchers","Infielders","Outfielders"]
  
  def initialize(team)
    return nil if team.nil?
    info = team.to_a
    @team = info[0]
    @url = info[1]
    html = getHtml(@url)
    return false if !html
    parseHtml(html)
  end
  
  def parseHtml(html)
    arr = []
    @teamNoCity = teamName(html)
    @roster = parseTables(html)
  end
  
  def parseTables(html)
    arr = []
    table = html.search("//table[@class='team_table_results']")[0]
    rows = (table/"tbody/tr")
    arr << parseStats(rows)
    arr.flatten
  end
  
  def teamName(html)
    m_name = ""
    domain = html.search("//body/div[@id='metaWrap']/div[@id='tw_interior']/div[@id='header_container']/div[@id='masthead']/div[@class='h_container']/h1/a/span")[0]
    domain = domain.inner_html
    @@team_city_list.each do |team|
      return team if domain.match(Regexp.new(team[:key],true))
    end
    return ""
  end
  
  #[number,name,team,city,link,position,bats,throws,age,height,weight]
  def parseStats(rows)
    arr = []
    rows.each do |row|
      hsh = {}
      stats = (row/"td")
      hsh["number"] = stats[0].inner_html.strip
      hsh["name"] = (stats[1]/"a").inner_html.strip
      hsh["team"] = @teamNoCity[:team] || ""
      hsh["city"] = @teamNoCity[:city] || ""
      hsh["link"] = "http://mlb.com" << (stats[1]/"a").attr("href").to_s.strip
      hsh["bats_throws"] = stats[2].inner_html.strip
      hsh["height"] = stats[3].inner_html.strip
      hsh["weight"] = stats[4].inner_html.strip
      hsh["dob"] = stats[5].inner_html.gsub(/\,/,"&#44;").strip
      arr << hsh
    end
    arr
  end
  
end

class RosterFile
  
  attr_accessor :file

  def initialize(filename)
    @writer = createFile(filename)
    @completeRoster = []
    @library = RosterUrls.new
    writePlayers
    rosterToFile
    @writer.close
    FileUtils.mv('mlbplayers_temp.csv',@filename)
    checkComplete
    p "Done!"
    return true
  end
  
  def createFile(filename)
    @filename = filename
    @filename = "mlbplayers.csv" if filename.nil?
    @temp_file = "mlbplayers_temp.csv"
    return CSV.open(@temp_file, "w")
  end
  
  def writePlayers_old
    @library.teams.each do |team|
        team = Team.new(team)
        team.roster.each do |player|
          temp_arr = []
          player.each { |k,v| 
            p v if k == "name"
            temp_arr << v 
          }
          @writer << temp_arr
        end
    end
  end
  
  def writePlayers
    arr = []
    count = 0
    @library.teams.each do |team|
        arr[count] = Thread.new { teamRoster(team) }
        count += 1
    end
    arr.map do |cell|
      cell.join
    end
  end
  
  def teamRoster(team)
    t = Team.new(team)
    t.roster.each do |player|
      temp_arr = []
      player.each { |k,v| 
        p v if k == "name"
        temp_arr << v 
      }
      @completeRoster << temp_arr
    end
  end
  
  def rosterToFile
    @completeRoster.each do |player|
      @writer << player
    end
  end
  
  def checkComplete
    initialize if File.exists?(@temp_file)
    return true
  end

end

begin 
  begin
    complete = RosterFile.new("../../../dumps/mlbplayers.csv")
  rescue Exception => err
    p "Error: " + err.message
    p err.backtrace.join("\n")
  end
end until complete








