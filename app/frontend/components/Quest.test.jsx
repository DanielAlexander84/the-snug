import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import Quest from "./Quest"

function questWith(steps) {
  return {
    id: 1,
    title: "Renew passport",
    user_email: "owner@example.com",
    steps: steps.map(([description, done], index) => ({ id: index + 1, description, done, position: index })),
  }
}

describe("Quest", () => {
  it("shows the title and each step, ticked or open, in the order given", () => {
    render(<Quest quest={questWith([["Find the old one", true], ["Take a photo", false]])} onToggleStep={jest.fn()} />)

    expect(screen.getByRole("heading", { name: "Renew passport" })).toBeInTheDocument()
    expect(screen.getAllByRole("listitem").map((item) => item.textContent)).toEqual(["Find the old one", "Take a photo"])
    expect(screen.getByRole("checkbox", { name: "Find the old one" })).toBeChecked()
    expect(screen.getByRole("checkbox", { name: "Take a photo" })).not.toBeChecked()
  })

  // WRONG TODAY (D16, R2): the owner's email is shown on every quest.
  it("shows the owner's email beside the title (D16, R2)", () => {
    render(<Quest quest={questWith([["Find the old one", false]])} onToggleStep={jest.fn()} />)

    expect(screen.getByText("owner@example.com")).toBeInTheDocument()
  })

  it("asks for a step to be changed when its checkbox is clicked, and does not change it itself", async () => {
    const onToggleStep = jest.fn()
    const quest = questWith([["Find the old one", false]])
    render(<Quest quest={quest} onToggleStep={onToggleStep} />)

    await userEvent.click(screen.getByRole("checkbox", { name: "Find the old one" }))

    expect(onToggleStep).toHaveBeenCalledWith(quest.steps[0])
    expect(screen.getByRole("checkbox", { name: "Find the old one" })).not.toBeChecked()
  })

  // WRONG TODAY (I2): the browser decides "lit". The accepted rule (D13) is
  // that the server sends a `completed` flag and the browser only shows it.
  describe("the lantern (I2)", () => {
    it("is lit when every step is ticked", () => {
      render(<Quest quest={questWith([["Find the old one", true], ["Take a photo", true]])} onToggleStep={jest.fn()} />)

      expect(screen.getByText("🏮 lit")).toBeInTheDocument()
    })

    it("is dark while any step is open", () => {
      render(<Quest quest={questWith([["Find the old one", true], ["Take a photo", false]])} onToggleStep={jest.fn()} />)

      expect(screen.queryByText("🏮 lit")).not.toBeInTheDocument()
    })

    it("is dark for a quest with no steps", () => {
      render(<Quest quest={questWith([])} onToggleStep={jest.fn()} />)

      expect(screen.queryByText("🏮 lit")).not.toBeInTheDocument()
    })
  })
})
