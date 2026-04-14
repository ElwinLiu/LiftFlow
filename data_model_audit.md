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
| `canonical_exercise_id` | uuid | Yes | FK to `canonical_exercises.id` when matched |
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

### Table: `canonical_exercises`

| Column | Type | Nullable | Notes |
| --- | --- | --- | --- |
| `id` | uuid | No | Primary key |
| `name` | text | No | Canonical exercise name |
| `aliases` | text | Yes | Comma-separated aliases, concatenated by `,` |
| `equipment_json` | jsonb | Yes | Optional equipment list |
| `notes` | text | Yes | Optional plain-text notes for short cues, caveats, or coaching reminders |
| `instructions` | text | Yes | Optional Markdown-backed how-to content rendered as formatted guidance in the UI |
| `created_at` | timestamptz | No | Creation time |
| `updated_at` | timestamptz | No | Last update time |

Recommended modeling note:

- use `notes` for short unformatted text
- use `instructions` for reusable exercise how-to content
- store Markdown in `instructions` and render it as formatted content in the client

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
