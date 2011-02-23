class Team

  attr_reader :list

  def initialize
    teams
  end
  
  def teams
    @list = [ { :team => "Orioles", :city => "Baltimore", :color => "#fb4f14", :backgroundPosition => "-20px -5px" },
              { :team => "Red Sox", :city => "Boston", :color => "#c60c30", :backgroundPosition => "-25px -6px" },
              { :team => "Yankees", :city => "New York", :color => "#002244", :backgroundPosition => "-24px -4px" },
              { :team => "Rays", :city => "Tampa Bay", :color => "#002147", :backgroundPosition => "-22px -7px" },
              { :team => "Blue Jays", :city => "Toronto", :color => "#005293", :backgroundPosition => "-22px -7px" },
              { :team => "White Sox", :city => "Chicago", :color => "#1e1e1e", :backgroundPosition => "-18px -7px" },
              { :team => "Indians", :city => "Cleveland", :color => "#002244", :backgroundPosition => "-18px -12px" },
              { :team => "Tigers", :city => "Detroit", :color => "#f9461c", :backgroundPosition => "-20px -11px" }, 
              { :team => "Royals", :city => "Kansas City", :color => "#002c77", :backgroundPosition => "-18px -8px" },
              { :team => "Twins", :city => "Minnesota", :color => "#002244", :backgroundPosition => "-20px -6px" },
              { :team => "Angels", :city => "Los Angeles", :color => "#b71234", :backgroundPosition => "-20px -10px" },
              { :team => "Athletics", :shortName => "A's", :city => "Oakland", :color => "#004438", :backgroundPosition => "-18px -7px" },
              { :team => "Mariners", :city => "Seattle", :color => "#002244", :backgroundPosition => "-22px -6px" },
              { :team => "Rangers", :city => "Texas", :color => "#002c77", :backgroundPosition => "-24px -6px" },
              { :team => "Braves", :city => "Atlanta", :color => "#002f5f", :backgroundPosition => "-20px -5px" },
              { :team => "Marlins", :city => "Florida", :color => "#009aa6", :backgroundPosition => "-20px -3px" }, 
              { :team => "Mets", :city => "New York", :color => "#002c77", :backgroundPosition => "-20px -7px" }, 
              { :team => "Phillies", :city => "Philadelphia", :color => "#b71234", :backgroundPosition => "-18px -7px" },
              { :team => "Nationals", :shortName => "Nats", :city => "Washington", :color => "#b71234", :backgroundPosition => "-20px -8px" },
              { :team => "Cubs", :city => "Chicago", :color => "#003478", :backgroundPosition => "-22px -6px" },
              { :team => "Reds", :city => "Cincinnati", :color => "#d0103A", :backgroundPosition => "-22px -7px" },
              { :team => "Astros", :city => "Houston", :color => "#d2c295", :backgroundPosition => "-15px -6px" },
              { :team => "Brewers", :city => "Milwaukee", :color => "#182b49", :backgroundPosition => "-20px -3px" },
              { :team => "Pirates", :city => "Pittsburgh", :color => "#fdc82f", :backgroundPosition => "-22px -6px" }, 
              { :team => "Cardinals", :city => "St. Louis", :color => "#b71234", :backgroundPosition => "-18px -4px" },
              { :team => "Diamondbacks", :shortName => "D-Backs", :city => "Arizona", :color => "#b82c3e", :backgroundPosition => "-25px -1px" },
              { :team => "Rockies", :city => "Colorado", :color => "#241773", :backgroundPosition => "-20px -6px" },
              { :team => "Dodgers", :city => "Los Angeles", :color => "#003478", :backgroundPosition => "-25px -4px" },
              { :team => "Padres", :city => "San Diego", :color => "#002147", :backgroundPosition => "-24px -6px" }, 
              { :team => "Giants", :city => "San Francisco", :color => "#f9461c", :backgroundPosition => "-25px -6px" } ]
  end  
  
  def findRow(team)
    return {} if team.nil?
    @list.each do |row|
      return row if(row[:team] == team)
    end
    {}
  end
  
  def randomTeam
    @list[(rand(@list.length)-1)]
  end
  
  def specificTeam(key = nil)
    return nil if key.nil?
    @list[key]
  end
  
end