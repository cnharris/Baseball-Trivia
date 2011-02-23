require 'uri'
require 'net/http'
require 'open-uri'
require 'hpricot'
require 'csv'
require 'timeout'
require 'fileutils'

class RosterUrls
  
  attr_reader :teams 
  DOMAIN = "espn.go.com"
  PLAYER_PATH = "/mlb/players"
  
  def initialize
    @domain = "espn.go.com"
    @playerPath = "/mlb/players"
    html = getHtml("http://#{DOMAIN}#{PLAYER_PATH}")
    return false if html.nil?
    @teams = parseHtml(html)
  end
  
  def getHtml(url)
    begin
      Timeout::timeout(10) do
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
    html.search("//a[@href^='/mlb/teams/roster?team=']") do |url|
      hsh[url.inner_html] = "http://#{DOMAIN}#{url.get_attribute('href')}"
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
    tables = validateTables(html)
    @teamNoCity = teamName(html)
    @roster = parseTables(tables)
  end
  
  def validateTables(html)
    arr = []
    tables = html.search("//table[@class='tablehead']").each do |table|
      stathead = (table/"tr[@class='stathead']")
      title = (stathead/"td").inner_html
      arr << table if stathead && POSITIONS.include?(title)
    end
    arr
  end
  
  def parseTables(tables)
    arr = []
    tables.each do |table|
      rows = (table/"[@class='oddrow']|[@class='evenrow']")
      arr << parseStats(rows)
    end
    arr.flatten
  end
  
  def teamName(html)
    last = html.search("//table[@class='tablehead']").last
    name = (last/"tr[@class='oddrow']/td[1]").inner_html
    return "" if name.nil?
    name
  end
  
  #[number,name,team,city,link,position,bats,throws,age,height,weight]
  def parseStats(rows)
    arr = []
    rows.each do |row|
      hsh = {}
      stats = (row/"td")
      hsh["number"] = stats[0].inner_html.strip
      hsh["name"] = (stats[1]/"a").inner_html.strip
      hsh["team"] = @teamNoCity.strip
      hsh["teamcity"] = @team.gsub(Regexp.new(@teamNoCity),"").to_s.strip
      hsh["link"] = "http://espn.go.com" << (stats[1]/"a").attr("href").to_s.strip
      hsh["position"] = stats[2].inner_html.strip
      hsh["bats"] = stats[3].inner_html.strip
      hsh["throws"] = stats[4].inner_html.strip
      hsh["age"] = stats[5].inner_html.strip
      hsh["height"] = stats[6].inner_html.strip
      hsh["weight"] = stats[7].inner_html.strip
      arr << hsh
    end
    arr
  end
  
end

class RosterFile
  
  attr_accessor :file

  def initialize(filename)
    @writer = createFile(filename)
    @library = RosterUrls.new
    writePlayers
    @writer.close
    convertTempToOriginal(@writer)
    checkComplete
    p "Done!"
    return true
  end
  
  def createFile(filename)
    @filename = filename
    @filename = "mlbplayers.csv" if filename.nil?
    @temp_file = "mlbplayers_temp.csv"
    return CSV.open(@temp_file, "w+")
  end
  
  def writePlayers
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
  
  def convertTempToOriginal(file)
    FileUtils.mv('mlbplayers_temp.csv',@filename)
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
  end
end until complete








