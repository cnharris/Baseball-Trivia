require "team"

class RetrieveController < ApplicationController
  
  LINEORDER = [:city,:name,:number,:dob,:weight,:bats_throws,:height,:link,:team]
  ANSWER_CHOICES = 4
  
  def random_player
    render :json => [random_line]
  end
  
  def random_line
    mlb_players = File.open("#{Rails.root}/dumps/mlbplayers.csv")
    return nil if mlb_players.blank?
    temp_arr = []
    count = 0
    mlb_players.each do |player|
      unless player.blank?
        temp_arr << player
        count += 1
      end
    end
    
    random_number = (rand(count)-1)
    result = temp_arr[random_number].split(",")
    
    hsh = {}
    count_cell = 0
    LINEORDER.each do |name|
      hsh[name] = result[count_cell].strip
      count_cell += 1
    end
  
    hsh
  end
  
  def save_stats
    valid_params = true
    params_data = ["score","name","total"]
    params_data.each do |data|
      valid_params = false if params[data].blank?
    end
    Scoreboard.new(params_data) if valid_data
    json = (valid_params ? { :status => 200, :response => "You score has been submitted." } : { :status => 500, :response => "Sorry, there was a problem."})
    render :json => json
  end
  
  def x_players(num_players = 2)
    num_param = params[:num_players]
    unless num_param.blank?
      num_param = num_param.to_i.round
      if num_param > 0 && num_param < 99
        num_players = num_param
      end
    end
    tracking_arr = []
    arr = []
    count = 10
    while arr.length <= num_players
      player = random_line
      unless tracking_arr.include?(player[:name])
        right_team = (Team.new.findRow(player[:team]) || { :team => player[:team], :city => player[:city] })
        player[:choices] = TeamGroup.new(player[:team]).group.insert(rand(ANSWER_CHOICES),right_team)
        arr << player
        tracking_arr << player[:name]
      end
    end

    render :json => { :total => arr.length-1, :results => arr }
  end
  
end
