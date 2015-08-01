class RemovePickInfoFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :picks
    remove_column :players, :formatted_picks
  end
end