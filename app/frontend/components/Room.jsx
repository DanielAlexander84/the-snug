import { useState } from "react"
import NewQuestForm from "./NewQuestForm"
import Quest from "./Quest"

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]').content
}

export default function Room({ initialData }) {
  const [quests, setQuests] = useState(initialData.quests)

  async function createQuest({ title, stepDescriptions }) {
    const response = await fetch("/quests", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({
        quest: {
          title,
          steps_attributes: stepDescriptions.map((description, index) => ({
            description,
            position: index,
          })),
        },
      }),
    })

    if (!response.ok) return

    const quest = await response.json()
    setQuests((current) => [...current, quest])
  }

  async function toggleStep(step) {
    const response = await fetch(`/steps/${step.id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken(),
      },
      body: JSON.stringify({ step: { done: !step.done } }),
    })

    if (!response.ok) return

    const updatedStep = await response.json()
    setQuests((current) =>
      current.map((quest) =>
        quest.id === updatedStep.quest_id
          ? { ...quest, steps: quest.steps.map((s) => (s.id === updatedStep.id ? updatedStep : s)) }
          : quest
      )
    )
  }

  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-2xl mb-1">{initialData.room_name}</h1>
      <p className="text-sm text-gray-500 mb-6">signed in as {initialData.current_user_email}</p>

      <NewQuestForm onSubmit={createQuest} />

      <div className="mt-8 space-y-4">
        {quests.map((quest) => (
          <Quest key={quest.id} quest={quest} onToggleStep={toggleStep} />
        ))}
      </div>
    </div>
  )
}
