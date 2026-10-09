class QuestsController < ApplicationController
  def index
    quests = Room.the_one.quests.includes(:steps, :user).order(:created_at)
    render json: quests.map { |quest| quest_json(quest) }
  end

  def create
    quest = current_user.quests.build(quest_params.merge(room: Room.the_one))

    if quest.save
      render json: quest_json(quest), status: :created
    else
      render json: { errors: quest.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def quest_params
    params.require(:quest).permit(:title, steps_attributes: [:description, :position])
  end

  def quest_json(quest)
    quest.as_json(only: [:id, :title], include: {
      steps: { only: [:id, :description, :done, :position] }
    }).merge(user_email: quest.user.email)
  end
end
