# LiftFlow Design Doc

## Status

Draft 5

## Date

April 14, 2026

## Overview

LiftFlow is an iOS-first workout app focused on turning messy workout ideas or chatbot-generated flows into structured, editable workout plans.

The main product value is not generic workout logging and not generic AI chat. The product value is a guided import workflow:

1. User creates or refines a flow outside the app
2. User pastes normalized workout text into LiftFlow
3. LiftFlow parses the text into structured workout data
4. LiftFlow detects missing or ambiguous fields
5. LiftFlow helps the user resolve issues manually or with AI suggestions
6. User reviews and saves the finished flow

## Goals

- Make flow import feel simple and reliable
- Minimize manual data entry
- Keep the user in control of AI-generated assumptions
- Build the MVP with low infrastructure cost and low operational complexity
- Use a stack that is realistic for an iOS-first solo product
- Keep core workout usage reliable even with poor gym connectivity

## Non-Goals For MVP

- Full cross-platform support
- Social features
- Advanced analytics
- Rich media exercise library at launch
- Complex trainer/admin tooling
- Fully offline-first synchronization

## Product Principles

### 1. Normalization first

The app should encourage users to normalize flows before import. This reduces parsing ambiguity and improves reliability.

### 2. Structured before saved

The app should not save raw AI output directly as a final flow. Imported text must become validated internal data first.

### 3. User control over AI

AI may suggest missing values, but suggestions must be clearly labeled and user-reviewable.

### 4. Draft before save

Imported content should become a reviewable draft before it becomes a saved flow.

## Proposed Tech Stack

### Client

- Language: Swift
- UI framework: SwiftUI
- App pattern: MVVM with modern SwiftUI state management
- Concurrency: async/await
- Client SDK: `supabase-swift`

### Managed Backend Platform

- Managed services: Supabase
- Database: PostgreSQL
- Auth: Supabase Auth
- Storage: Supabase Storage if needed later
- Server-side code: optional Supabase Edge Functions only for secret-dependent operations

### Local Persistence

- SwiftData for cached flows, import drafts, local session state, and pending sync operations

The app should be local-first for active usage. Supabase remains the cross-device source of truth, but the app should not depend on live network access for the core workout flow.

## Why This Stack

### Why SwiftUI

- The app is iPhone-first
- SwiftUI is the most natural choice for a new Apple-platform app
- The import and review flow is form-heavy and step-driven, which fits SwiftUI well

### Why Supabase

- It gives a managed PostgreSQL database
- It includes auth and storage in one product
- It removes most infrastructure setup for an MVP
- It has a free tier sufficient for early testing and a small initial user base

### Why PostgreSQL

- The core data is relational
- The app needs structured flows, flow exercises, flow exercise sets, and canonical exercise records
- Exercise name resolution benefits from SQL querying and fuzzy matching support

### Why Direct SwiftUI To Supabase

- It avoids the cost and operational overhead of hosting a custom backend service
- It matches the product goal of keeping as much MVP logic as possible inside the app
- Supabase already provides the hosted database, auth, and client access patterns needed for an iOS-first app
- It lets the app ship faster as long as data access is protected with strong Row Level Security policies

### Why Local-First App State

- Gym connectivity is often unreliable, so the app should remain usable without stable network access
- Draft editing, flow review, and already-fetched workout data should feel instant
- Local-first state reduces user-visible latency and turns sync into a background concern instead of a blocking interaction
- Supabase still works well as the remote system of record across devices

### Why Edge Functions Only When Needed

- Secret-dependent features such as AI suggestions should not live in the mobile app
- Edge Functions give a small server-side surface without requiring a full custom backend
- This keeps the default architecture simple while leaving room for secure server-side work later

### Why Not CloudKit As Primary Backend

CloudKit is a valid Apple-native sync option, but it is not the best center of gravity for this product. LiftFlow needs backend-style logic:

- parsing imported text
- applying validation rules
- generating AI suggestions
- resolving imported exercise names against canonical data

Those workflows are easier to build and maintain around a managed relational backend. For MVP, parsing, validation, and most resolution logic can live in the app, while secret-dependent AI operations can move to Edge Functions later.

## System Architecture

### High-Level Flow

1. User copies a normalization prompt from the app
2. User pastes the prompt into a chatbot and gets normalized workout text
3. User pastes normalized text into LiftFlow
4. LiftFlow parses the text into structured draft data locally
5. LiftFlow validates structural completeness of the draft locally
6. LiftFlow resolves exercise names against canonical exercise records using locally cached data when available
7. LiftFlow stores drafts and pending edits locally first
8. LiftFlow syncs drafts and finalized flows to Supabase when connectivity is available
9. If a secret-dependent AI action is needed later, LiftFlow calls a Supabase Edge Function for suggestions when online
10. User reviews and edits the draft in the app
11. User saves the finalized flow

## MVP Components

### iOS App Screens

#### 1. Import Entry Screen

- Shows the normalization prompt
- Allows copy-to-clipboard
- Accepts pasted workout text
- Starts the import flow

#### 2. Import Review Screen

- Displays parsed exercises in flow order
- Highlights missing required fields
- Shows AI-generated suggestions separately from confirmed values
- Lets the user edit fields
- Lets the user resolve exercise matches

#### 3. Save Confirmation Screen

- Shows the final flow summary
- Saves validated flow data

### Supabase And Server-Side Responsibilities

#### 1. Database And Auth

Responsibility:
- store flows, flow exercises, sets, canonical exercises, and import drafts
- authenticate users with Supabase Auth
- enforce row access with RLS
- receive synced changes from the app and provide cross-device persistence

#### 2. Optional Edge Functions

Responsibility:
- call AI providers securely when the feature requires server-held secrets
- run any privileged or server-only workflows that should not live in the client

### App Responsibilities

#### 1. Parse Import Locally

Responsibility:
- accept pasted normalized text
- convert text into an initial structured flow draft

#### 2. Validate Draft Locally

Responsibility:
- validate required draft fields
- mark unresolved or incomplete items

#### 3. Resolve Exercises In The App

Responsibility:
- map imported exercise names to canonical exercise records fetched from Supabase
- use deterministic matching first and fuzzy matching second
- show candidate matches if confidence is not high enough

#### 4. Persist Locally First

Responsibility:
- store import drafts, cached flows, and pending changes locally
- keep the active workout flow usable without requiring live network access

#### 5. Sync With Supabase

Responsibility:
- upload pending local changes when connectivity is available
- fetch canonical exercise updates and remote flow changes
- track sync state so the UI can show whether local changes are pending or synced

## Data Model

The current database source of truth is [data_model_audit.md](/Users/elwin/code/LiftFlow/data_model_audit.md).

At a high level, the database currently centers on:

- `flows`
- `flow_exercises`
- `flow_exercise_sets`
- `canonical_exercises`
- `import_drafts`

Important simplifications in the current model:

- flows contain an ordered list of exercises directly
- sets are stored separately in `flow_exercise_sets`
- there is no `flow_sections` table
- `exercise_type` is currently a flow-facing classification: `warmup`, `workout`, or `stretch`
- aliases are stored on `canonical_exercises.aliases` as a comma-separated field
- canonical exercise instructional content should be split between plain `notes` and formatted `instructions`

## AI Usage Plan

AI should be used conservatively and only on the server side.

### Approved AI Roles

- normalize text into a predictable structure when needed
- suggest missing values when the product later decides that is appropriate
- help map imported names to canonical exercises

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

## Data Access Shape

The app should use local-first data access with direct authenticated sync to Supabase.

### Local-First Access

- read drafts and cached flows from local storage first
- save edits locally first
- keep a queue of pending writes when offline

### Direct Supabase Access

- sync import drafts, flows, flow exercises, and flow exercise sets
- refresh canonical exercises into the local cache
- authenticate the current user

### Optional Edge Function Calls

- suggest missing values with AI
- any future privileged workflow that requires secret keys or trusted execution

## Security And Trust Boundaries

- Enable RLS on every exposed table in `public`
- The iOS app may ship with the Supabase project URL and publishable key, but never with secret or service-role credentials
- Imported text should be treated as untrusted input
- AI calls that require secrets must happen in Edge Functions, not in the iOS client
- If the app writes directly to Supabase, write permissions must be constrained by user-scoped RLS policies
- Local cached data should be treated as user device state, not as the only durable copy

## Offline And Sync Strategy

### Offline-Capable Operations

- viewing already-fetched flows and drafts
- parsing imported workout text
- validating draft structure
- editing drafts
- saving pending changes locally

### Network-Required Operations

- first-time sign in
- first sync on a new device
- fetching updated canonical exercises that are not already cached
- AI suggestion requests
- syncing local changes to Supabase

### Sync Model

- save locally first
- mark records as pending sync
- push changes in the background when connectivity is available
- retry failed sync operations later
- surface sync state in the UI when relevant

## Cost Plan

### MVP Cost Assumption

- iOS app: SwiftUI
- backend: Supabase free tier during development and early testing
- expected user count: very small, roughly 10 active users initially

This keeps infrastructure cost near zero while preserving a path to cross-device sync and acceptable offline behavior.

## Delivery Plan

### Phase 1: UX And Data Model

- define flow, flow exercise, flow exercise set, and canonical exercise schemas
- build import entry and review UI in SwiftUI
- create Supabase tables
- define initial RLS policies
- define local persistence models for cached flows, drafts, and pending sync state

### Phase 2: Parsing And Validation

- implement local parsing in the app
- implement structural validation rules
- return structured review payloads

### Phase 3: Exercise Resolution

- create canonical exercise table
- add alias support
- add fuzzy matching
- cache canonical exercise data locally

### Phase 4: Local-First Sync

- save drafts and flow edits locally first
- build background sync to Supabase
- expose sync status in the UI when needed

### Phase 5: AI Suggestions

- add Edge Function based suggestion flow for missing values
- expose suggestions in the review UI

### Phase 6: Save And Polish

- save finalized flows
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

### 5. Sync Complexity

Local-first architecture improves reliability, but introduces sync state and conflict handling. The MVP should keep conflict rules simple and avoid overly complex multi-device editing semantics.

## Open Questions

- Should MVP require user accounts immediately, or can early test users operate with anonymous Supabase sessions?
- Should import drafts be persisted server-side from day one, or only held in app memory until save?
- How large should the initial canonical exercise library be?
- Should the app support custom user-created exercises in MVP?

## Final Recommendation

Build LiftFlow as an iOS-first app using SwiftUI on the client and Supabase as the managed backend platform.

Use a local-first app architecture with direct client-to-Supabase sync for MVP data operations, protected by Supabase Auth and RLS. Keep server-side code optional and limited to Supabase Edge Functions for AI suggestions or other secret-dependent work.

Use PostgreSQL as the system of record. Treat [data_model_audit.md](/Users/elwin/code/LiftFlow/data_model_audit.md) as the current source of truth for the database shape.

This gives the product a low-cost MVP path, keeps the architecture operationally simple, and supports reliable usage even when gym connectivity is poor.
