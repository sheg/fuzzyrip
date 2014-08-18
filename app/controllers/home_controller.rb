class HomeController < ApplicationController

  def index
    @players = Player.all
  end

  def show
    @player = Player.find_by(id: params[:id])
  end

end
