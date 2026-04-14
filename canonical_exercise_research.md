# Canonical Exercise Research

Date researched: 2026-04-14

Assumption:

- The user said "Heavy." I treated that as [Hevy](https://www.hevyapp.com/), which appears to be the intended app.

## What I Verified

### Strong

- Strong says it includes "over 200 built in exercises in the Exercise Library, including Instructions and Videos."
  Source: [Strong Help Center: How do I create a custom exercise?](https://help.strongapp.io/article/97-create-custom-exercises)
- Strong's exercise detail screen includes step-by-step instructions plus video or image instructions.
  Source: [Strong Help Center: About Exercise Detail Screen](https://help.strongapp.io/article/237-about-exercise-detail)
- Strong positions the built-in library and templates as starter content for common training programs, but it does not publicly expose a machine-readable full exercise list.
  Source: [Strong Help Center: What's the best way to train with Strong?](https://help.strongapp.io/article/236-best-way-to-train)

### Hevy

- Hevy says its exercise library has "400+ high-quality exercises."
  Source: [Hevy Help Center: Hevy Exercise Library: 400+ Exercises and Custom Exercises](https://help.hevyapp.com/hc/en-us/articles/35688251991575-Hevy-Exercise-Library-400-Exercises-and-Custom-Exercises)
- Hevy exposes useful canonical exercise metadata in the app: name, required equipment, primary muscle, secondary muscles, and exercise type.
  Source: [Hevy Help Center: How to Create Custom Exercises in Hevy](https://help.hevyapp.com/hc/en-us/articles/35700328894103-How-to-Create-Custom-Exercises-in-Hevy)
- Hevy's current leaderboard feature is limited to a smaller set of major exercises, mostly barbell-based. This is the best official popularity / importance signal I found.
  Source: [Hevy Help Center: Hevy Exercise Leaderboard: How It Works and Where to Find It](https://help.hevyapp.com/hc/en-us/articles/38224023680407-Hevy-Exercise-Leaderboard-How-It-Works-and-Where-to-Find-It)
- Hevy also has a public marketing page for leaderboards that still claims 38 included exercises. I am treating the help center article as the current product source of truth and the marketing page as supplemental naming evidence only.
  Source: [Hevy: Gym Leaderboards: See How You Rank Among Friends](https://www.hevyapp.com/features/gym-leaderboard/)
- Hevy also publishes a public exercise sitemap. When fetched on 2026-04-14, it exposed 124 exercise URLs. This is useful for naming and instructions research, but it is not the full in-app library because the help center says the app library contains 400+ exercises.

### Shared media library

- Hevy exercise pages embed demonstration videos from `https://pump-app.s3.eu-west-2.amazonaws.com/exercise-assets/...` with standardized numeric filenames such as `02891201-Dumbbell-Bench-Press_Chest.mp4`.
- I also found the same filename conventions reused outside Hevy on third-party fitness sites, which suggests these assets come from a shared third-party catalog rather than an app-exclusive media set.
- I did **not** find a public Strong source that exposes the same asset URLs, so "Strong and Hevy definitely share the exact same media library" is still an inference, not a verified fact.

## Implications For The Embedded Catalog

Our current Swift-side exercise definition should carry:

- `key`
- `name`
- `aliases`
- `equipment`
- `notes`
- `instructions`

This maps cleanly to the public app research:

- `name`: should use the app-facing exercise display name
- `aliases`: should absorb common import variants
- `key`: gives each exercise a stable persisted identifier
- `equipment`: can carry the coarse equipment group
- `instructions`: can later reuse condensed how-to text from public exercise pages

It does **not** currently have columns for:

- primary muscle
- secondary muscles
- exercise type
- media asset references

That is fine for MVP, but these are obvious future extensions if canonical resolution becomes more important.

## Naming Recommendation

Use app-style display names as the canonical `name`, with an equipment suffix only when needed to disambiguate variants.

Examples:

- `Bench Press (Barbell)`
- `Bench Press (Dumbbell)`
- `Lat Pulldown (Cable)`
- `Leg Press (Machine)`
- `Pull Up`

This is closer to how Hevy surfaces exercises, and it avoids collisions once you add multiple bench, curl, row, and squat variants.

## Recommended First Embedded Batch

This batch is intentionally biased toward common lifts and obvious import targets, not maximum catalog coverage.

### Tier 1: strongest signal

These are the best first candidates because they are explicitly surfaced in Hevy's current leaderboard feature.

| Canonical name | Suggested aliases | Suggested `equipment` | Why include now | Source signal |
| --- | --- | --- | --- | --- |
| `Bench Press (Barbell)` | `Barbell Bench Press, Bench Press` | `["barbell","bench"]` | Most common chest press import target | Hevy leaderboard + Hevy public exercise page |
| `Bicep Curl (Barbell)` | `Barbell Curl, Barbell Biceps Curl` | `["barbell"]` | Common beginner and hypertrophy movement | Hevy leaderboard + Hevy public exercise page |
| `Deadlift (Barbell)` | `Barbell Deadlift, Conventional Deadlift` | `["barbell"]` | Core lower-body / posterior-chain lift | Hevy leaderboard |
| `Hip Thrust (Barbell)` | `Barbell Hip Thrust` | `["barbell","bench"]` | Very common glute movement in modern programs | Hevy leaderboard + Hevy public exercise page |
| `Leg Press (Machine)` | `Machine Leg Press, Leg Press` | `["machine"]` | Common lower-body machine import target | Hevy leaderboard |
| `Romanian Deadlift (Barbell)` | `Barbell Romanian Deadlift, RDL, Barbell RDL` | `["barbell"]` | High-frequency hinge variation | Hevy leaderboard |
| `Skullcrusher (Barbell)` | `Barbell Skullcrusher, Lying Triceps Extension (Barbell)` | `["barbell","bench"]` | Common triceps isolation movement | Hevy leaderboard |
| `Squat (Barbell)` | `Barbell Squat, Back Squat` | `["barbell","rack"]` | Core squat import target | Hevy leaderboard |

### Tier 2: still high-value for MVP coverage

These are publicly exposed by Hevy exercise pages and/or repeatedly used across Hevy programming content.

| Canonical name | Suggested aliases | Suggested `equipment` | Why include now | Source signal |
| --- | --- | --- | --- | --- |
| `Bench Press (Dumbbell)` | `Dumbbell Bench Press, DB Bench Press` | `["dumbbells","bench"]` | Extremely common flat press variant | Hevy public exercise page |
| `Bench Press - Close Grip (Barbell)` | `Close Grip Bench Press, Close-Grip Bench Press` | `["barbell","bench"]` | Common triceps-focused press variant | Hevy public exercise page |
| `Bench Press - Wide Grip (Barbell)` | `Wide Grip Bench Press, Wide-Grip Bench Press` | `["barbell","bench"]` | Common chest-focused bench variant | Hevy public exercise page |
| `Incline Bench Press (Barbell)` | `Barbell Incline Bench Press, Incline Barbell Press` | `["barbell","incline bench"]` | Common upper-chest press variation | Hevy public exercise page |
| `Incline Bench Press (Dumbbell)` | `Dumbbell Incline Bench Press, Incline Dumbbell Press` | `["dumbbells","incline bench"]` | Very common upper-chest accessory | Hevy public exercise page + Hevy leaderboard marketing page |
| `Bent Over Row (Barbell)` | `Barbell Row, Barbell Bent-Over Row` | `["barbell"]` | Core pull movement in many programs | Hevy leaderboard marketing page + Hevy pull-exercise guide |
| `Pendlay Row (Barbell)` | `Pendlay Row` | `["barbell"]` | Common row variant in strength programs | Hevy public exercise page |
| `Overhead Press (Barbell)` | `Barbell Overhead Press, Shoulder Press (Barbell), OHP` | `["barbell"]` | Core vertical press import target | Hevy leaderboard marketing page + Hevy shoulder-exercise guide |
| `Seated Overhead Press (Barbell)` | `Seated Barbell Overhead Press, Seated Shoulder Press (Barbell)` | `["barbell","bench"]` | Common seated press variation | Hevy public exercise page |
| `Pull Up` | `Pull-Up, Pullup` | `["pull-up bar"]` | Essential bodyweight pull movement | Hevy public exercise page |
| `Lat Pulldown (Cable)` | `Cable Lat Pulldown, Lat Pulldown` | `["cable"]` | Very common pull alternative to pull-ups | Hevy public exercise page + Hevy pull-exercise guide |
| `T-Bar Row` | `T Bar Row, T-Bar Row (Machine)` | `["machine","barbell"]` | Common horizontal pull in gym programs | Hevy public exercise page |
| `Goblet Squat` | `Goblet Squat (Dumbbell), Goblet Squat (Kettlebell)` | `["dumbbell","kettlebell"]` | Common beginner-friendly squat pattern | Hevy public exercise page |
| `Reverse Lunge` | `Reverse Lunge (Barbell), Reverse Lunge (Dumbbell)` | `["barbell","dumbbells"]` | Common unilateral lower-body import target | Hevy public exercise page |
| `Split Squat (Dumbbell)` | `Dumbbell Split Squat` | `["dumbbells"]` | Common unilateral leg movement | Hevy public exercise page |
| `Lateral Raise (Dumbbell)` | `Dumbbell Lateral Raise, Side Lateral Raise` | `["dumbbells"]` | Very common shoulder isolation exercise | Hevy public exercise page + Hevy shoulder-exercise guide |
| `Hammer Curl (Dumbbell)` | `Dumbbell Hammer Curl` | `["dumbbells"]` | Common biceps / brachialis accessory | Hevy public exercise page |
| `Triceps Rope Pushdown` | `Rope Pushdown, Cable Rope Pushdown, Tricep Rope Pushdown` | `["cable","rope attachment"]` | Common cable triceps isolation movement | Hevy public exercise page |
| `Glute Bridge` | `Bodyweight Glute Bridge, Floor Glute Bridge` | `[]` | Common beginner / rehab / warm-up movement | Hevy public exercise page |
| `Chest Dip` | `Dip, Chest Dip (Bodyweight)` | `["dip bars"]` | Common bodyweight chest / triceps movement | Hevy public exercise page |

Useful supplemental Hevy sources for names and variants:

- [Hevy: Gym Leaderboards: See How You Rank Among Friends](https://www.hevyapp.com/features/gym-leaderboard/)
- [Hevy: 8 Pull Exercises For a Big Back](https://www.hevyapp.com/pull-exercises/)
- [Hevy: 8 Isolation and 9 Compound Shoulder Exercises](https://www.hevyapp.com/compound-isolation-shoulder-exercises/)

## Suggested Insert Order

If we want to keep the first seed tight, I would insert in this order:

1. `Bench Press (Barbell)`
2. `Squat (Barbell)`
3. `Deadlift (Barbell)`
4. `Overhead Press (Barbell)`
5. `Bent Over Row (Barbell)`
6. `Pull Up`
7. `Lat Pulldown (Cable)`
8. `Bench Press (Dumbbell)`
9. `Incline Bench Press (Barbell)`
10. `Incline Bench Press (Dumbbell)`
11. `Romanian Deadlift (Barbell)`
12. `Leg Press (Machine)`
13. `Hip Thrust (Barbell)`
14. `Goblet Squat`
15. `Reverse Lunge`
16. `Lateral Raise (Dumbbell)`
17. `Bicep Curl (Barbell)`
18. `Hammer Curl (Dumbbell)`
19. `Triceps Rope Pushdown`
20. `Chest Dip`

## Recommended Next Step

When we actually expand the embedded Swift catalog, I recommend:

1. Start with the 20-row seed list above.
2. Keep `instructions` empty for the first pass unless we want to curate concise Markdown manually.
3. Use `aliases` aggressively for import matching.
4. Persist only the selected exercise `key` on saved flow rows.
5. Add a later model revision for muscle groups and exercise type if matching quality is not good enough with just names and aliases.
