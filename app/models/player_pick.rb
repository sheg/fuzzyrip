class PlayerPick < ActiveRecord::Base

  belongs_to :player
  belongs_to :pick

end
