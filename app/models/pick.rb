class Pick < ActiveRecord::Base

  has_many :player_picks
  has_many :players, through: :player_picks


  # stripped_picks = picks.reject { |pick| pick == "n/a" }
  # stripped_formatted_picks = formatted_picks.reject { |pick| pick == "n/a" }

end