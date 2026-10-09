# Finds things in the room the way a person does: by the words on the screen,
# never by CSS class, so the restyle (D18) does not break these tests.
module RoomPageHelpers
  def lantern
    "🏮 lit"
  end

  # The card of the quest with this title: the smallest box that holds both
  # the title and its list of steps.
  def quest_card(title)
    find(:xpath, "//h2[normalize-space()=#{title.to_json}]/ancestor::*[.//ul][1]")
  end

  def quest_titles
    all("h2").map(&:text)
  end

  def steps_shown_in(card)
    card.all("li").map(&:text)
  end

  def step_boxes
    all(:xpath, "//input[starts-with(@placeholder, 'Step ')]")
  end

  def struck_through?(text)
    find("span", exact_text: text).style("text-decoration-line")["text-decoration-line"] == "line-through"
  end

  # Marks the loaded page so a test can tell whether a later change arrived
  # without a full page reload.
  def mark_page
    execute_script("window.__samePage = true")
  end

  def same_page?
    evaluate_script("window.__samePage === true")
  end
end

RSpec.configure do |config|
  config.include RoomPageHelpers, type: :system
end
