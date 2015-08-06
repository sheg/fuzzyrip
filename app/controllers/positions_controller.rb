class PositionsController < ApplicationController

  def index
    @players = Player.all.sort_by { |player| player.average_total_pick }
  end

end