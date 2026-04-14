# LiftFlow Data Model Audit

## Purpose

This document contains the current proposed database tables only.

It intentionally avoids backend business logic, validation rules, parsing flow, and API behavior.

## Tables

### Table: `flows`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | uuid | No | Primary key |
| `user_id` | uuid | No | Owning user, FK to `auth.users.id` |
| `title` | text | No | Flow title |
| `description` | text | Yes | Optional flow description |
| `notes` | text | Yes | Optional flow notes |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

### Table: `flow_exercises`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | uuid | No | Primary key for the flow-specific exercise entry |
| `flow_id` | uuid | No | FK to `flows.id` |
| `canonical_exercise_key` | text | Yes | Stable app-defined exercise key when matched against the embedded Swift catalog |
| `order_index` | integer | No | Exercise order within the flow |
| `original_name` | text | No | Original imported or user-entered name |
| `display_name` | text | No | Name shown in the UI |
| `exercise_type` | text | No | `warmup`, `workout`, or `stretch` |
| `notes` | text | Yes | Optional exercise notes |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

### Table: `flow_exercise_sets`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | uuid | No | Primary key |
| `flow_exercise_id` | uuid | No | FK to `flow_exercises.id` |
| `order_index` | integer | No | Set order within the flow exercise |
| `reps` | integer | Yes | Optional rep count |
| `duration_value` | numeric | Yes | Optional duration value for the set |
| `duration_unit` | text | Yes | Optional duration unit such as `sec` or `min` |
| `rest_seconds` | integer | Yes | Optional rest after the set |
| `weight_value` | numeric | Yes | Optional programmed weight |
| `weight_unit` | text | Yes | Optional weight unit such as `kg` or `lb` |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

## Embedded Reference Data

Canonical exercises are no longer modeled as a server table.

They should live in the Swift app bundle as embedded reference data with:

- a stable `key`
- a display `name`
- `aliases` for import matching
- optional `equipment`
- optional `notes`
- optional `instructions`

The database only needs to persist the selected `canonical_exercise_key` on each `flow_exercises` row.

### Table: `import_drafts`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | uuid | No | Primary key |
| `user_id` | uuid | Yes | Optional for anonymous draft handling, FK to `auth.users.id` |
| `raw_input` | text | No | Natural language input or pasted normalized text |
| `draft_json` | jsonb | No | Serialized draft payload |
| `status` | text | No | Draft lifecycle state |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |
