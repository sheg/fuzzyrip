class AddPositionToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :position_id, :integer
  end
end
