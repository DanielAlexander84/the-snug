import { render, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import Room from "../../../app/frontend/components/Room"

const initialData = {
  room_name: "The Snug",
  current_user_email: "me@example.com",
  quests: [
    {
      id: 1,
      title: "Renew passport",
      user_email: "me@example.com",
      steps: [{ id: 10, description: "Find the old one", done: false, position: 0 }],
    },
  ],
}

function answer(status, body) {
  return { ok: status >= 200 && status < 300, status, json: async () => body }
}

async function startQuest(title, step) {
  await userEvent.type(screen.getByPlaceholderText("Name your quest"), title)
  await userEvent.type(screen.getByPlaceholderText("Step 1"), step)
  await userEvent.click(screen.getByRole("button", { name: "Start quest" }))
}

describe("Room", () => {
  beforeEach(() => {
    document.head.innerHTML = '<meta name="csrf-token" content="token-from-the-page">'
    global.fetch = jest.fn()
  })

  it("shows the room name, who is signed in and the quests it was given", () => {
    render(<Room initialData={initialData} />)

    expect(screen.getByRole("heading", { level: 1, name: "The Snug" })).toBeInTheDocument()
    expect(screen.getByText("signed in as me@example.com")).toBeInTheDocument()
    expect(screen.getByRole("heading", { level: 2, name: "Renew passport" })).toBeInTheDocument()
  })

  describe("starting a quest", () => {
    it("sends the quest to the server with the page's CSRF token and numbered steps", async () => {
      fetch.mockResolvedValue(answer(201, { id: 2, title: "Call the bank", user_email: "me@example.com", steps: [] }))
      render(<Room initialData={initialData} />)

      await startQuest("Call the bank", "Find the number")

      expect(fetch).toHaveBeenCalledTimes(1)
      const [address, request] = fetch.mock.calls[0]
      expect(address).toBe("/quests")
      expect(request.method).toBe("POST")
      expect(request.headers).toEqual({ "Content-Type": "application/json", "X-CSRF-Token": "token-from-the-page" })
      expect(JSON.parse(request.body)).toEqual({
        quest: { title: "Call the bank", steps_attributes: [{ description: "Find the number", position: 0 }] },
      })
    })

    it("adds what the server answered to the bottom of the list", async () => {
      fetch.mockResolvedValue(
        answer(201, {
          id: 2,
          title: "Title as the server saved it",
          user_email: "me@example.com",
          steps: [{ id: 20, description: "Step as the server saved it", done: false, position: 0 }],
        })
      )
      render(<Room initialData={initialData} />)

      await startQuest("Call the bank", "Find the number")

      const titles = (await screen.findAllByRole("heading", { level: 2 })).map((heading) => heading.textContent)
      expect(titles).toEqual(["Renew passport", "Title as the server saved it"])
      expect(screen.getByRole("checkbox", { name: "Step as the server saved it" })).not.toBeChecked()
    })

    // WRONG TODAY (R14): a rejected quest fails silently, and the form is
    // emptied, so what the person typed is lost.
    it("says nothing and empties the form when the server rejects the quest (R14)", async () => {
      fetch.mockResolvedValue(answer(422, { errors: ["Title can't be blank"] }))
      render(<Room initialData={initialData} />)

      await startQuest("Call the bank", "Find the number")

      await waitFor(() => expect(screen.getByPlaceholderText("Name your quest")).toHaveValue(""))
      expect(screen.getAllByRole("heading", { level: 2 })).toHaveLength(1)
      expect(screen.queryByText("Title can't be blank")).not.toBeInTheDocument()
    })
  })

  describe("ticking a step", () => {
    it("asks the server for the opposite of what is shown", async () => {
      fetch.mockResolvedValue(answer(200, { id: 10, quest_id: 1, description: "Find the old one", done: true, position: 0 }))
      render(<Room initialData={initialData} />)

      await userEvent.click(screen.getByRole("checkbox", { name: "Find the old one" }))

      const [address, request] = fetch.mock.calls[0]
      expect(address).toBe("/steps/10")
      expect(request.method).toBe("PATCH")
      expect(request.headers).toEqual({ "Content-Type": "application/json", "X-CSRF-Token": "token-from-the-page" })
      expect(JSON.parse(request.body)).toEqual({ step: { done: true } })
    })

    it("shows the step ticked only once the server has answered", async () => {
      let respond
      fetch.mockReturnValue(new Promise((resolve) => (respond = resolve)))
      render(<Room initialData={initialData} />)

      await userEvent.click(screen.getByRole("checkbox", { name: "Find the old one" }))

      expect(screen.getByRole("checkbox", { name: "Find the old one" })).not.toBeChecked()
      expect(screen.queryByText("🏮 lit")).not.toBeInTheDocument()

      respond(answer(200, { id: 10, quest_id: 1, description: "Find the old one", done: true, position: 0 }))

      await waitFor(() => expect(screen.getByRole("checkbox", { name: "Find the old one" })).toBeChecked())
      expect(screen.getByText("🏮 lit")).toBeInTheDocument()
    })

    // WRONG TODAY (R14): a refused change fails silently.
    it("changes nothing and says nothing when the server refuses (R14)", async () => {
      fetch.mockResolvedValue(answer(403, { errors: ["not your quest"] }))
      render(<Room initialData={initialData} />)

      await userEvent.click(screen.getByRole("checkbox", { name: "Find the old one" }))

      await waitFor(() => expect(fetch).toHaveBeenCalled())
      expect(screen.getByRole("checkbox", { name: "Find the old one" })).not.toBeChecked()
      expect(screen.queryByText("not your quest")).not.toBeInTheDocument()
    })
  })
})
