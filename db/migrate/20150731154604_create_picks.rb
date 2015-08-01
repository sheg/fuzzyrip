class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.string :round
      t.integer :total

      t.timestamps
    end
  end
end
