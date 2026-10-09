FactoryBot.define do
  factory :quest do
    user
    room { Room.first || association(:room) }
    sequence(:title) { |n| "Quest #{n}" }

    transient do
      # Step descriptions, in order. Nothing is ticked unless listed in `done`.
      step_descriptions { [ "First step" ] }
      done { [] }
    end

    after(:build) do |quest, evaluator|
      evaluator.step_descriptions.each_with_index do |description, index|
        quest.steps.build(description: description, position: index, done: evaluator.done.include?(description))
      end
    end
  end
end
