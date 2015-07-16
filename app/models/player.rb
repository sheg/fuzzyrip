require 'watir-webdriver'

class Array
  def sum
    self.inject(0){|accum, i| accum + i }
  end

  def mean
    self.sum/self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum +(i-m)**2 }
    sum/(self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
end


class Player < ActiveRecord::Base
  include Enumerable

  validates_uniqueness_of :name

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
