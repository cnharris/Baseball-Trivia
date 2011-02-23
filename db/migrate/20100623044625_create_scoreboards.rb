class CreateScoreboards < ActiveRecord::Migration
  def self.up
    create_table :scoreboards do |t|
      t.string :name
      t.string :total
      t.string :score
      t.string :sid, :auto_increment
      t.timestamps
    end
  end

  def self.down
    drop_table :scoreboards
  end
end
