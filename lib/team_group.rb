class TeamGroup < Team
  
  attr_accessor :group
  
  def initialize(exclude = nil)
    @group = []
    @count = 3
    @exclude = exclude
    buildGroup
    return @group
  end
  
  def buildGroup
    while @group.length < @count
      addTeamToGroup
    end
  end
  
  def addTeamToGroup
    team = Team.new.randomTeam
    if !@group.include?(team) && @exclude != team[:team]
      @group << team 
    end
  end
  
end