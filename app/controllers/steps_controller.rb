class StepsController < ApplicationController
  def update
    step = Step.find(params[:id])

    unless step.quest.user == current_user
      return render json: { errors: ["not your quest"] }, status: :forbidden
    end

    if step.update(step_params)
      render json: step.as_json(only: [:id, :quest_id, :description, :done, :position])
    else
      render json: { errors: step.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def step_params
    params.require(:step).permit(:done)
  end
end
