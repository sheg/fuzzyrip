module PickHelper

  def convert_total_pick(pick_total)
    round = ((pick_total - 1) /   12) + 1
    pick = pick_total - (round - 1)*12
    "#{round}.#{pick}"
  end

  def filter_position(players, position)
    players.select { |player| player.position.name == position }
  end
end