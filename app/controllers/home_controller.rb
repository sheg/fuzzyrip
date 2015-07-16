class HomeController < ApplicationController

  def index
    @players = Player.all.sort_by { |player| player.average_total_pick }
  end

  def show
    @player = Player.find_by(id: params[:id])
  end
end