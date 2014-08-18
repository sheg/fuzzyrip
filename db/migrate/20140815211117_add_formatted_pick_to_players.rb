class AddFormattedPickToPlayers < ActiveRecord::Migration
  def change

    add_column :players, :formatted_picks, :string, :array => true


  end
end