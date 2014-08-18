class AddPlayerTable < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :picks, array: true
    end
  end
end
