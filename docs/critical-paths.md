# Critical Paths

<!-- The 5 to 10 things that must never break. Each one has an end-to-end test. Written as user steps, not code. -->

Onboarding Phase 1, written 2026-10-09 from the code on `main` at `59cd4ef`. Approved by Daniel in chat the same day.

These are the things a real person can do in The Snug today. Each one gets an end-to-end test in Phase 2 that pins the behaviour exactly as described here, including the parts marked **WRONG TODAY**. Those are pinned so that a change is noticed, not because they are wanted. Each has a backlog entry in `docs/STATUS.md`.

Phase 2 tests find things by the visible words and labels quoted below, not by CSS classes, so the restyle (D18) does not break them. Changing a quoted text later means changing its test in the same PR.

## The paths

| # | Path | Steps | Test |
|---|---|---|---|
| 1 | Sign up | See below | Phase 2 |
| 2 | Sign in by magic link | See below | Phase 2 |
| 3 | A signed-out visitor is sent to sign-in | See below | Phase 2 |
| 4 | Opening the room shows its quests | See below | Phase 2 |
| 5 | Create a quest with steps | See below | Phase 2 |
| 6 | Tick and untick a step | See below | Phase 2 |
| 7 | The last step lights the lantern | See below | Phase 2 |
| 8 | Nobody can change someone else's step | See below | Phase 2 |

### 1. Sign up

1. A visitor opens the sign-in page and follows "Sign up".
2. On "Pull up a chair" they type an email address nobody has used and press "Sign up".
3. They are in the room straight away, with the message "Welcome! You have signed up successfully." and "signed in as" followed by their email.

Also pinned:
- An address that already has an account, or one that is not an email address, stays on the sign-up page with an error and creates nothing.
- Capitals and surrounding spaces are ignored: " Me@Example.com " and "me@example.com" are the same account.

**WRONG TODAY (R19):** no email is sent and nothing checks that the visitor owns the address. Anyone can type someone else's email and is signed in as that account. When the real owner later asks for a magic link, they land in the same account, with whatever the first person left there.

### 2. Sign in by magic link

1. A person with an account opens the sign-in page, "Come into the snug".
2. They type their email and press "Send me a magic link".
3. They stay on the sign-in page and see "A login link has been sent to your email address. Please follow the link to log in to your account."
4. An email arrives with the subject "Here's your magic login link ✨" and a link "Log in to my account".
5. They open the link and are in the room, with "Signed in successfully." and "signed in as" followed by their email.

Also pinned:
- An email with no account stays on the sign-in page with "Could not find a user for that email address". No email is sent.
- A link that has been tampered with or is older than 20 minutes does not sign anyone in. The visitor sees "Invalid or expired login link."

**WRONG TODAY (R3):** the same link works again and again until its 20 minutes are up. **WRONG TODAY (R20):** the "Could not find a user" message tells anyone whether a given email has an account.

### 3. A signed-out visitor is sent to sign-in

1. Someone who is not signed in opens the room (the home page or `/room`).
2. They land on the sign-in page with "You need to sign in or sign up before continuing." and see no quests.

Also pinned: without being signed in, a request to create a quest or change a step is refused and changes nothing.

### 4. Opening the room shows its quests

1. A signed-in person opens the room.
2. They see the room name, "The Snug", and "signed in as" followed by their own email.
3. They see every quest in the room, oldest first. Each shows its title, its steps in the order they were typed, and which steps are ticked.
4. A room with no quests shows the form and an empty list.

**WRONG TODAY (D16, R2):** the list holds everyone's quests, not only the viewer's, each in full and with its owner's email beside it. The accepted rule is that the owner chooses per quest what the room sees, and that no email is ever shown to another person.

### 5. Create a quest with steps

1. A signed-in person types a title under "What are you starting?".
2. They type one or more steps under "Steps". Three boxes are there to begin with; "+ add a step" adds another.
3. They press "Start quest".
4. The quest appears at the bottom of the list without a page reload, with its steps in the order typed and none ticked. The form is empty again.
5. After a reload the quest is still there.

Also pinned:
- Step boxes left empty are dropped, and the remaining steps keep their order.
- With no title, or with no step filled in, pressing "Start quest" does nothing and keeps what was typed.

### 6. Tick and untick a step

1. A signed-in person ticks a step on their own quest. It shows as ticked and struck through.
2. After a reload it is still ticked.
3. They untick it. It shows as open again, and stays open after a reload.

### 7. The last step lights the lantern

1. A person ticks every step of their own quest except one. No lantern shows.
2. They tick the last step. "🏮 lit" appears on that quest.
3. After a reload it still shows "🏮 lit".
4. They untick any step. "🏮 lit" disappears.

Other people in the room see "🏮 lit" on that quest the next time they load the page.

**WRONG TODAY (I2):** the browser works out "lit" by itself and the server records nothing. No lantern event is stored and nobody else is told. The accepted rule (D13) is that the server decides.

### 8. Nobody can change someone else's step

1. Person A has a quest with an unticked step.
2. Person B, signed in, sees A's quest and clicks the checkbox on A's step.
3. Nothing changes on B's screen. After a reload, and on A's screen, the step is still unticked.

Also pinned: B cannot create a quest in A's name. A quest always belongs to whoever is signed in when it is made.

**WRONG TODAY (I3):** the server answers "not yours" for A's step and "not found" for a step that does not exist, which tells B which steps exist. The accepted rule (D13) is "not found" for both. B also gets no message explaining why nothing happened (R14).

## Not built yet

Each of these arrives with its own spec. Those marked **critical once built** join the table above, with an end-to-end test, in the same PR as the feature.

- **Critical once built:** Sage breaks a task into small steps (the AI breakdown)
- **Critical once built:** deleting an account and its data
- **Critical once built:** signing out. There is no control for it in the UI today (R5), so there is no user path to describe. The sign-out address itself already exists; Phase 2 pins that it ends the session, with a test that calls it directly. The full path is added when the control is built.
- Another person taps "saw that" on a finished quest (witnessing)
- A lit lantern is recorded and shown to the room as it happens
- Choosing "say it plainly" or "keep it vague" per quest, and display names in place of emails (D16)
- Coming back after time away, without guilt

## Decided with Daniel (2026-10-09)

- Sign-up without proof of the email address (R19) is pinned as it is in Phase 2 and fixed later with a spec.
- Sign-out is critical, but later. Phase 2 pins only what exists (see above).
- The Sage breakdown and account deletion become critical paths when they are built.
