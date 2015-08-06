class HomeController < ApplicationController

  def index
    @players = Player.all.sort_by { |player| player.average_total_pick }
  end

  def show
    @player = Player.find_by(id: params[:id])
    @picks = @player.picks.map { |pick| pick.total }.sort
  end

  def destroy
    @player_id = params[:id]
    Player.destroy(@player_id)
    respond_to do |format|
      format.js
    end
  end
end