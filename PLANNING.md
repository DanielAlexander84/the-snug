# THE SNUG — HIGH-LEVEL OVERVIEW
<!-- Coarse on purpose. Allowed to be wrong. Revisit only on direction change.
     Once code exists: repo root as PLANNING.md -->

## The point
A cozy co-working tavern for people who struggle to start. You name a task,
take one tiny step in warm company, and a human sees you finish. The lantern
is the only reward.

## Rough architecture
- Rails monolith (Postgres-only: SolidQueue, solid_cable). Server owns ALL
  state transitions and the lantern policy.
- Devise magic-link auth — prerequisite for realtime identity (ActionCable
  reads the session cookie).
- One Room. Quests → Steps → completion event → lantern broadcast.
- React front end talking to a clean Rails API + ActionCable channel.
  Client only renders broadcasts + local UI state. No optimistic updates.
- Anthropic API for Sage's breakdown — a LATER piece, one endpoint, canned
  fallback.

## Major chunks
1. Walking skeleton: auth → room → hand-typed quest → done → lantern ⚠
2. Witnessing: presence + "saw that ✓" from another human ⚠ (the whole bet)
3. Sage breakdown via API (with fallback)
4. Warmth pass: privacy masking, chime/copy polish, shame-free re-entry copy
5. Deploy + run the live alpha sessions with 5–10 ADHD friends

## Rough sequence
1 → 2 → deploy early → 3 → 4, with alpha sessions starting as soon as 2 works.
The risky chunks (1, 2) are first on purpose; 3 and 4 only matter if 2 feels warm.

# THE SNUG — Slice Map

**The point:** name a task, start it in warm company, a human sees you finish.
**First "done":** signed-in me completes a hand-typed quest in the one room;
a second signed-in tab sees the lantern light live, and can tap "saw that ✓".

## Slices
- ▶ CURRENT: Walking skeleton — Devise magic-link, one hardcoded Room, create
  quest + type 3–4 steps yourself, check steps, completion lights a lantern
  (event row + broadcast + soft chime), and a one-tap "saw that ✓" witness
  action from another signed-in tab. Server-authoritative throughout. This
  is the whole bet, so it's tested in the skeleton, not deferred.
- next: Who's-here presence — presence list showing who else is in the room
  right now. (The "saw that" tap already lives in slice one; this slice is
  just presence.)
- next: Sage breakdown — one Anthropic API call: task in, 3–4 steps + a
  "start here" out, editable before saving, canned template on API failure.

## Later, maybe
- Privacy masking ("a quiet quest") — cheap (boolean + display conditional);
  jumps the queue the moment strangers join, not before
- Your Quests personal log page (plain index)
- Murmurs (~200-char free text) + reaction palette beyond "saw that ✓"
- Sage ambient host messages / greeting
- Dim-the-lights focus toggle, sound settings beyond the one chime
- Scheduled-sessions model, multiple rooms, "next session" logic
- Witnessed-by attribution lines on individual steps
- Example task chips, mobile polish, Tome/scroll, Tapestry (already sequenced)

## Decisions (closed)
- No AI in skeleton; steps hand-typed — alpha tests witnessing, Daniel plays
  Sage by hand — CLOSED
- One always-open room; "scheduled session" = banner + calendar invite — kills
  a scheduling subsystem — CLOSED
- Rails + React, Postgres-only, no Redis — production stack, no reason to
  diverge — CLOSED
- Steps stored as rows (not JSON blob) — Rails-native, trivial now, annoying
  to migrate later — CLOSED
- The "saw that ✓" witness tap moves into slice one (walking skeleton), not
  slice two — being witnessed by a person is the core bet, so the skeleton
  should test the feeling, not just the realtime transport — CLOSED
- Real Devise magic-link auth ships in slice one, not a hardcoded identity —
  realtime identity needs it (ActionCable reads the session cookie) and it's
  cheap to build now — CLOSED

## Decisions (open)
- (none)

---
<details>
<summary>📜 Shipped — full quest log (append-only)</summary>

</details>
