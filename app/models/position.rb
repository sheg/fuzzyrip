class Position < ActiveRecord::Base

  POSITION_TYPES = %W{QB RB TE WR K D}

  validate :is_valid_type?
  validates_uniqueness_of :name

  has_many :players

  def is_valid_type?
    unless POSITION_TYPES.include? self.name
      errors.add(self.name, "invalid position type")
    end
  end
end