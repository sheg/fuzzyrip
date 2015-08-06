class Player < ActiveRecord::Base

  validates_uniqueness_of :name

  has_many :player_picks
  has_many :picks, through: :player_picks

  belongs_to :position

  def average_round_pick
    if !self.picks.empty?
      total_average = average_total_pick.round
      round = (total_average - 1) / 12 + 1
      pick = total_average - (round - 1)*12
      "#{round}.#{pick}"
    else
      "n/a"
    end
  end

  def average_total_pick
    if !self.picks.empty?
      sum = self.picks.map { |pick| pick.total }.reduce(:+)
      sum / self.picks.length
    else
      0
    end
  end

  def min_pick
    if !self.picks.empty?
      picks = self.picks.map { |pick| pick.total }
      pick_total = picks.sort.first
      round = ((pick_total - 1) / 12) + 1
      pick = pick_total - (round - 1)*12
      "#{round}.#{pick}"
    else
      "n/a"
    end
  end

  def max_pick
    if !self.picks.empty?
      picks = self.picks.map { |pick| pick.total }
      pick_total = picks.sort.last
      round = ((pick_total - 1) /   12) + 1
      pick = pick_total - (round - 1)*12
      "#{round}.#{pick}"
    else
      "n/a"
    end
  end
end

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
    Math.sqrt(self.sample_variance)
  end
end