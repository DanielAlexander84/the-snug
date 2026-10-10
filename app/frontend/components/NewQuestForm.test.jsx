import { render, screen, waitFor } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import NewQuestForm from "./NewQuestForm"

function stepBoxes() {
  return screen.getAllByPlaceholderText(/^Step \d+$/)
}

describe("NewQuestForm", () => {
  it("starts with three step boxes and adds another on '+ add a step'", async () => {
    render(<NewQuestForm onSubmit={jest.fn()} />)

    expect(stepBoxes()).toHaveLength(3)

    await userEvent.click(screen.getByRole("button", { name: "+ add a step" }))

    expect(stepBoxes()).toHaveLength(4)
  })

  it("hands over the trimmed title and the filled-in steps, in order", async () => {
    const onSubmit = jest.fn().mockResolvedValue()
    render(<NewQuestForm onSubmit={onSubmit} />)

    await userEvent.type(screen.getByPlaceholderText("Name your quest"), "  Renew passport ")
    await userEvent.type(screen.getByPlaceholderText("Step 1"), " Find the old one ")
    await userEvent.type(screen.getByPlaceholderText("Step 3"), "Take a photo")
    await userEvent.click(screen.getByRole("button", { name: "Start quest" }))

    expect(onSubmit).toHaveBeenCalledTimes(1)
    expect(onSubmit).toHaveBeenCalledWith({
      title: "Renew passport",
      stepDescriptions: ["Find the old one", "Take a photo"],
    })
  })

  it("empties the form once the quest has been handed over", async () => {
    render(<NewQuestForm onSubmit={jest.fn().mockResolvedValue()} />)
    await userEvent.click(screen.getByRole("button", { name: "+ add a step" }))
    await userEvent.type(screen.getByPlaceholderText("Name your quest"), "Renew passport")
    await userEvent.type(screen.getByPlaceholderText("Step 4"), "Post it")

    await userEvent.click(screen.getByRole("button", { name: "Start quest" }))

    expect(screen.getByPlaceholderText("Name your quest")).toHaveValue("")
    expect(stepBoxes().map((box) => box.value)).toEqual(["", "", ""])
  })

  it("does nothing without a title, and keeps what was typed", async () => {
    const onSubmit = jest.fn()
    render(<NewQuestForm onSubmit={onSubmit} />)
    await userEvent.type(screen.getByPlaceholderText("Name your quest"), "   ")
    await userEvent.type(screen.getByPlaceholderText("Step 1"), "Find the old one")

    await userEvent.click(screen.getByRole("button", { name: "Start quest" }))

    expect(onSubmit).not.toHaveBeenCalled()
    expect(screen.getByPlaceholderText("Step 1")).toHaveValue("Find the old one")
  })

  it("does nothing when every step box is empty or blank, and keeps the title", async () => {
    const onSubmit = jest.fn()
    render(<NewQuestForm onSubmit={onSubmit} />)
    await userEvent.type(screen.getByPlaceholderText("Name your quest"), "Renew passport")
    await userEvent.type(screen.getByPlaceholderText("Step 2"), "   ")

    await userEvent.click(screen.getByRole("button", { name: "Start quest" }))

    expect(onSubmit).not.toHaveBeenCalled()
    expect(screen.getByPlaceholderText("Name your quest")).toHaveValue("Renew passport")
  })

  it("disables 'Start quest' while the quest is being saved", async () => {
    let finish
    const onSubmit = jest.fn(() => new Promise((resolve) => (finish = resolve)))
    render(<NewQuestForm onSubmit={onSubmit} />)
    await userEvent.type(screen.getByPlaceholderText("Name your quest"), "Renew passport")
    await userEvent.type(screen.getByPlaceholderText("Step 1"), "Find the old one")

    await userEvent.click(screen.getByRole("button", { name: "Start quest" }))

    expect(screen.getByRole("button", { name: "Start quest" })).toBeDisabled()

    finish()

    await waitFor(() => expect(screen.getByRole("button", { name: "Start quest" })).toBeEnabled())
  })
})
