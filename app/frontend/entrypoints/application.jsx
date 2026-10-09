import { createRoot } from "react-dom/client"
import Room from "../components/Room"

const mountEl = document.getElementById("room-root")

if (mountEl) {
  const dataEl = document.getElementById("room-data")
  const initialData = JSON.parse(dataEl.textContent)

  createRoot(mountEl).render(<Room initialData={initialData} />)
}
