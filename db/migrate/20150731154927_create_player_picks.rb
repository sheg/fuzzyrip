class CreatePlayerPicks < ActiveRecord::Migration
  def change
    create_table :player_picks do |t|
      t.integer :player_id
      t.integer :pick_id

      t.timestamps
    end
  end
end
