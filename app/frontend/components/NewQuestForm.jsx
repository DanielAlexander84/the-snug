import { useState } from "react"

export default function NewQuestForm({ onSubmit }) {
  const [title, setTitle] = useState("")
  const [steps, setSteps] = useState(["", "", ""])
  const [submitting, setSubmitting] = useState(false)

  function updateStep(index, value) {
    setSteps((current) => current.map((step, i) => (i === index ? value : step)))
  }

  function addStepField() {
    setSteps((current) => [...current, ""])
  }

  async function handleSubmit(event) {
    event.preventDefault()

    const stepDescriptions = steps.map((s) => s.trim()).filter(Boolean)
    if (!title.trim() || stepDescriptions.length === 0) return

    setSubmitting(true)
    await onSubmit({ title: title.trim(), stepDescriptions })
    setSubmitting(false)
    setTitle("")
    setSteps(["", "", ""])
  }

  return (
    <form onSubmit={handleSubmit} className="border rounded p-4">
      <div className="mb-3">
        <label className="block text-sm mb-1">What are you starting?</label>
        <input
          className="border rounded px-2 py-1 w-full"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Name your quest"
        />
      </div>

      <div className="mb-3 space-y-2">
        <label className="block text-sm mb-1">Steps</label>
        {steps.map((step, index) => (
          <input
            key={index}
            className="border rounded px-2 py-1 w-full"
            value={step}
            onChange={(e) => updateStep(index, e.target.value)}
            placeholder={`Step ${index + 1}`}
          />
        ))}
        <button type="button" onClick={addStepField} className="text-sm text-gray-500">
          + add a step
        </button>
      </div>

      <button type="submit" disabled={submitting} className="border rounded px-3 py-1">
        Start quest
      </button>
    </form>
  )
}
