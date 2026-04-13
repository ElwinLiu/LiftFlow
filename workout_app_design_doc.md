# LiftFlow Design Doc

## Status

Draft 1

## Date

April 12, 2026

## Overview

LiftFlow is an iOS-first workout app focused on turning messy workout ideas or chatbot-generated routines into structured, editable workout plans.

The main product value is not generic workout logging and not generic AI chat. The product value is a guided import workflow:

1. User creates or refines a routine outside the app
2. User pastes normalized workout text into LiftFlow
3. LiftFlow parses the text into structured workout data
4. LiftFlow detects missing or ambiguous fields
5. LiftFlow helps the user resolve issues manually or with AI suggestions
6. User reviews and saves the finished routine

## Goals

- Make routine import feel simple and reliable
- Minimize manual data entry
- Keep the user in control of AI-generated assumptions
- Build the MVP with low infrastructure cost and low operational complexity
- Use a stack that is realistic for an iOS-first solo product

## Non-Goals For MVP

- Full cross-platform support
- Social features
- Advanced analytics
- Rich media exercise library at launch
- Complex trainer/admin tooling
- Fully offline-first synchronization

## Product Principles

### 1. Normalization first

The app should encourage users to normalize routines before import. This reduces parsing ambiguity and improves reliability.

### 2. Structured before saved

The app should not save raw AI output directly as a final routine. Imported text must become validated internal data first.

### 3. User control over AI

AI may suggest missing values, but suggestions must be clearly labeled and user-reviewable.

### 4. Exercise-aware validation

Different exercise types require different fields. Validation should reflect exercise type instead of forcing one uniform schema.

## Proposed Tech Stack

### Client

- Language: Swift
- UI framework: SwiftUI
- App pattern: MVVM with modern SwiftUI state management
- Concurrency: async/await
- Networking: URLSession

### Backend

- Platform: Supabase
- Database: PostgreSQL
- Server-side language: TypeScript
- Server-side runtime: Supabase Edge Functions

### Optional Local Persistence

- SwiftData for draft caching and local session state if needed

This should be treated as optional in MVP. The primary source of truth should be the backend database.

## Why This Stack

### Why SwiftUI

- The app is iPhone-first
- SwiftUI is the most natural choice for a new Apple-platform app
- The import and review flow is form-heavy and step-driven, which fits SwiftUI well

### Why Supabase

- It gives a managed PostgreSQL database
- It includes auth, storage, and server functions in one product
- It removes most infrastructure setup for an MVP
- It has a free tier sufficient for early testing and a small initial user base

### Why PostgreSQL

- The core data is relational
- The app needs structured routines, sections, exercises, aliases, and canonical exercise records
- Exercise name resolution benefits from SQL querying and fuzzy matching support

### Why TypeScript On The Backend

- It is the default, low-friction choice for Supabase Edge Functions
- It works well for JSON request/response handling
- It is a pragmatic choice for calling AI APIs and shaping structured responses

### Why Not CloudKit As Primary Backend

CloudKit is a valid Apple-native sync option, but it is not the best center of gravity for this product. LiftFlow needs backend-style logic:

- parsing imported text
- applying validation rules
- generating AI suggestions
- resolving imported exercise names against canonical data

Those workflows are easier to build and maintain around a managed backend plus relational database.

## System Architecture

### High-Level Flow

1. User copies a normalization prompt from the app
2. User pastes the prompt into a chatbot and gets normalized workout text
3. User pastes normalized text into LiftFlow
4. LiftFlow sends the text to the backend import endpoint
5. Backend parses the text into structured draft data
6. Backend validates required fields by exercise type
7. Backend resolves exercise names against canonical exercise records
8. Backend returns:
   - parsed routine draft
   - validation issues
   - exercise match candidates
   - AI suggestions for safe-to-suggest missing values
9. User reviews and edits the draft in the app
10. User saves the finalized routine

## MVP Components

### iOS App Screens

#### 1. Import Entry Screen

- Shows the normalization prompt
- Allows copy-to-clipboard
- Accepts pasted workout text
- Starts the import flow

#### 2. Import Review Screen

- Displays parsed sections and exercises
- Highlights missing required fields
- Shows AI-generated suggestions separately from confirmed values
- Lets the user edit fields
- Lets the user resolve exercise matches

#### 3. Save Confirmation Screen

- Shows the final routine summary
- Saves validated routine data

### Backend Services

#### 1. Parse Import Function

Responsibility:
- accept pasted normalized text
- convert text into an initial structured routine draft

#### 2. Validate Draft Function

Responsibility:
- apply exercise-type-aware validation rules
- mark missing required fields
- separate required, optional, and inferable values

#### 3. Exercise Resolution Function

Responsibility:
- map imported exercise names to canonical exercise records
- use aliases and fuzzy matching
- return candidate matches if confidence is not high enough

#### 4. Suggest Missing Values Function

Responsibility:
- generate suggestions only for fields safe to suggest
- return values as suggestions, not confirmed data

#### 5. Save Routine Function

Responsibility:
- accept user-confirmed routine data
- persist final validated routine records

## Data Model

### Core Entities

#### users

Stores application users.

#### routines

Top-level saved workout routine.

Suggested fields:
- id
- user_id
- title
- goal
- source_type
- created_at
- updated_at

#### routine_sections

Logical sections within a routine.

Suggested fields:
- id
- routine_id
- title
- position

#### routine_exercises

Exercises within a section.

Suggested fields:
- id
- routine_section_id
- canonical_exercise_id
- original_name
- exercise_type
- position
- sets
- reps
- duration_seconds
- rest_seconds
- distance_value
- distance_unit
- side
- rounds
- notes

#### canonical_exercises

Master exercise records used for tracking and analytics.

Suggested fields:
- id
- name
- exercise_type
- equipment
- is_active

#### exercise_aliases

Alternative names for canonical exercises.

Suggested fields:
- id
- canonical_exercise_id
- alias

#### import_drafts

Temporary server-side import session state.

Suggested fields:
- id
- user_id
- raw_text
- parsed_payload_json
- validation_payload_json
- status
- created_at
- updated_at

## Validation Rules

Validation should depend on exercise type.

Examples:

- strength exercise
  - required: sets, reps
  - optional: rest, notes

- cardio exercise
  - required: duration or distance
  - optional: intensity, notes

- isometric exercise
  - required: sets, hold duration
  - optional: rest, notes

- mobility exercise
  - required: duration or rounds
  - optional: side, notes

Validation results should distinguish:

- missing required field
- optional missing field
- suggested value available
- unresolved exercise identity

## AI Usage Plan

AI should be used conservatively and only on the server side.

### Approved AI Roles

- normalize text into a predictable structure when needed
- suggest missing values for fields that can be reasonably inferred
- help classify ambiguous exercise types when deterministic rules are insufficient

### AI Rules

- AI output must be converted into a strict JSON shape
- AI output must be validated before use
- AI suggestions must never be silently saved as confirmed user data
- The user must explicitly review AI-generated assumptions before final save

## Exercise Resolution Strategy

Resolution should be deterministic first and fuzzy second.

### Match Order

1. Exact canonical name match
2. Exact alias match
3. Normalized string match
4. Fuzzy similarity match
5. User selection fallback

### Resolution Output

Each imported exercise should return:

- resolved canonical exercise id if confidence is high
- a confidence score
- candidate matches if confidence is not high enough
- unmatched status if no acceptable candidate exists

## API Shape

The API should remain simple for MVP.

### POST /import/parse

Request:
- raw normalized workout text

Response:
- import draft id
- parsed routine draft

### POST /import/validate

Request:
- import draft id or draft payload

Response:
- validation issues
- required missing fields
- optional missing fields

### POST /import/resolve-exercises

Request:
- parsed exercise names and context

Response:
- canonical matches
- candidate matches
- unresolved items

### POST /import/suggest

Request:
- draft payload plus unresolved fields

Response:
- suggested values with explanation metadata

### POST /routines

Request:
- final user-confirmed routine payload

Response:
- saved routine id

## Security And Trust Boundaries

- AI calls must happen on the server, not in the iOS client
- Service credentials must never ship in the app bundle
- The app should authenticate requests using normal user auth once auth is added
- Imported text should be treated as untrusted input
- Final save should require server-side validation

## Cost Plan

### MVP Cost Assumption

- iOS app: SwiftUI
- backend: Supabase free tier during development and early testing
- expected user count: very small, roughly 10 active users initially

This keeps infrastructure cost near zero while preserving a path to scale beyond local-only storage.

## Delivery Plan

### Phase 1: UX And Data Model

- define routine, section, exercise, and canonical exercise schemas
- build import entry and review UI in SwiftUI
- create Supabase tables

### Phase 2: Parsing And Validation

- implement parse function
- implement validation rules by exercise type
- return structured review payloads

### Phase 3: Exercise Resolution

- create canonical exercise table
- add alias support
- add fuzzy matching

### Phase 4: AI Suggestions

- add server-side suggestion flow for missing values
- expose suggestions in the review UI

### Phase 5: Save And Polish

- save finalized routines
- refine error states
- improve import confidence and review UX

## Risks

### 1. Normalized Input Quality

Even with a prompt, chatbot output may still vary. The system should expect imperfect input.

### 2. Exercise Matching Ambiguity

Some exercise names will be hard to resolve automatically. The UI must make manual correction easy.

### 3. Overuse Of AI

If AI is allowed to silently infer too much, user trust will drop. Suggestions must remain explicit.

### 4. Premature Complexity

The MVP should not attempt to solve every workout format. It should optimize for a narrow, reliable import flow first.

## Open Questions

- Should MVP require user accounts immediately, or can early test users operate with anonymous or local-only sessions?
- Should import drafts be persisted server-side from day one, or only held in app memory until save?
- How large should the initial canonical exercise library be?
- Should the app support custom user-created exercises in MVP?

## Final Recommendation

Build LiftFlow as an iOS-first app using SwiftUI on the client and Supabase on the backend.

Use PostgreSQL as the system of record and TypeScript Edge Functions for parsing, validation, exercise resolution, and AI suggestions.

This gives the product a low-cost MVP path, keeps the architecture simple, and directly supports the core workflow of turning rough workout text into reliable structured routines.
