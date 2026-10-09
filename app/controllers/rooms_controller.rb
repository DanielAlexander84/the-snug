class RoomsController < ApplicationController
  def show
    @room = Room.the_one
    @quests = @room.quests.includes(:steps, :user).order(:created_at)
  end
end
