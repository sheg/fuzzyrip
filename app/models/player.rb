require 'watir-webdriver'

class Player < ActiveRecord::Base

  def average_total_pick
    numeric_picks = formatted_numeric_picks
    numeric_picks.sum.to_f / numeric_picks.length
  end

  def average_round_pick
    total_average = average_total_pick.round
    round = (total_average - 1) / 12 + 1
    pick = total_average - (round - 1)*12
    "#{round}.#{pick}"
  end

  def formatted_numeric_picks
    picks = self.formatted_picks
    picks.map { |pick| pick.to_i }
  end
end
