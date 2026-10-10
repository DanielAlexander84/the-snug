# Migration safety gate (docs/agentic/quality-gates.md).
#
# Baseline: the five migrations that existed when the gate was switched on in
# onboarding Phase 3 are not checked. Everything newer is. Moving this number
# forward exempts migrations from the gate, so it is a protected setting.
StrongMigrations.start_after = 20260703195042
