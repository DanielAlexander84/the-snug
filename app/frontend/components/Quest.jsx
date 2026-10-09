export default function Quest({ quest, onToggleStep }) {
  const allDone = quest.steps.length > 0 && quest.steps.every((s) => s.done)

  return (
    <div className={`border rounded p-4 ${allDone ? "bg-amber-50" : ""}`}>
      <div className="flex justify-between items-baseline">
        <h2 className="font-medium">{quest.title}</h2>
        <span className="text-xs text-gray-500">{quest.user_email}</span>
      </div>
      <ul className="mt-2 space-y-1">
        {quest.steps.map((step) => (
          <li key={step.id}>
            <label className="flex items-center gap-2">
              <input type="checkbox" checked={step.done} onChange={() => onToggleStep(step)} />
              <span className={step.done ? "line-through text-gray-400" : ""}>{step.description}</span>
            </label>
          </li>
        ))}
      </ul>
      {allDone && <p className="mt-2 text-sm text-amber-700">🏮 lit</p>}
    </div>
  )
}
