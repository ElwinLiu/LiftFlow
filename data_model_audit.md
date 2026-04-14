# LiftFlow Data Model Audit

## Purpose

This document contains the current proposed database tables only.

It intentionally avoids backend business logic, validation rules, parsing flow, and API behavior.

## Tables

### Table: `routines`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | UUID or text | No | Primary key |
| `user_id` | UUID or text | No | Owning user |
| `title` | text | No | Routine title |
| `goal` | text | Yes | Optional goal |
| `notes` | text | Yes | Optional routine notes |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

### Table: `routine_exercises`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | UUID or text | No | Primary key for the routine-specific exercise entry |
| `routine_id` | UUID or text | No | FK to `routines.id` |
| `canonical_exercise_id` | UUID or text | Yes | FK to `canonical_exercises.id` when matched |
| `order_index` | integer | No | Exercise order within the routine |
| `original_name` | text | No | Original imported or user-entered name |
| `display_name` | text | No | Name shown in the UI |
| `exercise_type` | text | No | `warmup`, `workout`, or `stretch` |
| `notes` | text | Yes | Optional exercise notes |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

### Table: `routine_exercise_sets`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | UUID or text | No | Primary key |
| `routine_exercise_id` | UUID or text | No | FK to `routine_exercises.id` |
| `order_index` | integer | No | Set order within the routine exercise |
| `reps` | integer | Yes | Optional rep count |
| `duration_seconds` | integer | Yes | Optional timed set duration |
| `rest_seconds` | integer | Yes | Optional rest after the set |
| `distance_value` | numeric | Yes | Optional distance value |
| `distance_unit` | text | Yes | Optional distance unit |
| `weight_value` | numeric | Yes | Optional programmed weight |
| `weight_unit` | text | Yes | Optional weight unit such as `kg` or `lb` |
| `notes` | text | Yes | Optional set notes |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

### Table: `canonical_exercises`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | UUID or text | No | Primary key |
| `name` | text | No | Canonical exercise name |
| `equipment_json` | jsonb | Yes | Optional equipment list |
| `is_active` | boolean | No | Soft-active flag |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

### Table: `exercise_aliases`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | UUID or text | No | Primary key |
| `canonical_exercise_id` | UUID or text | No | FK to `canonical_exercises.id` |
| `alias` | text | No | Alternate exercise name for matching |
| `created_at` | timestamptz | No | Creation time |

### Table: `import_drafts`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | UUID or text | No | Primary key |
| `user_id` | UUID or text | Yes | Optional for anonymous draft handling |
| `raw_input` | text | No | Natural language input or pasted normalized text |
| `draft_json` | jsonb | No | Serialized draft payload |
| `status` | text | No | Draft lifecycle state |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |
