# Workout App High-Level Workflow

## Goal

Help users turn messy workout ideas or chatbot-generated flows into clean, structured, editable flows inside the app with minimal friction.

## Core Principle

The app should hide technical implementation details from most users. The experience should feel like guided flow import, not manual data entry or developer tooling.

## High-Level Workflow

### 1. User plans their workout outside the app
The user talks with a chatbot about their goals, health condition, schedule, equipment, and exercise preferences. The chatbot produces a draft flow, but that flow is often incomplete, inconsistent, or not structured enough for direct import.

### 2. App provides a normalization prompt
The app gives the user a reusable prompt template. The user copies this prompt into their chatbot so the chatbot can rewrite the flow into a more predictable format.

The normalized flow should include the key workout fields the app needs, such as:
- exercise type
- sets or set details
- reps or duration
- rest time
- notes
- other relevant exercise-specific information

This step is called refinement or normalization.

### 3. User pastes the normalized flow into the app
After the chatbot rewrites the flow into the expected format, the user pastes the result back into the app.

### 4. App parses the flow into structured internal data
The app reads the pasted flow and converts it into the app’s internal workout structure.

At this stage, the app should:
- identify exercises in order
- extract exercise fields
- classify exercise type
- prepare data for validation and saving

### 5. App validates the imported flow
The app checks whether each exercise has the required information.

Examples of potentially required information include:
- exercise identity
- exercise type
- any set-level details the flow needs

The app should distinguish between:
- required fields
- optional fields
- fields that can be inferred or suggested

### 6. App handles missing information
When required information is missing, the app should not silently guess and save incomplete data.

Instead, it should offer two paths:

#### Path A: User fills in the missing information
Use this when the missing information is too important or ambiguous to infer safely.

#### Path B: AI suggests missing values
Use this when the missing fields can reasonably be generated based on exercise type, flow context, and training intent.

These generated values should be clearly presented as suggestions, not facts.

### 7. App resolves exercises to canonical records
Exercise names from chatbot output may vary. The app should map imported exercise names to canonical exercises in the app database.

This may use:
- alias mapping
- fuzzy matching
- fallback selection or creation flow

In the current database direction, aliases are stored on the canonical exercise record rather than in a separate alias table.

The goal is to make sure imported flows connect to the correct exercise records for tracking, media, and analytics.

Canonical exercise records may also carry reusable reference content for display, including:
- `notes` for short plain-text guidance
- `instructions` for Markdown-backed how-to content rendered in the UI

### 8. User reviews and edits the flow
Before saving, the app presents the structured result in a clean review screen.

The user should be able to:
- confirm parsed exercises
- edit fields
- accept or reject AI-generated suggestions
- resolve unmatched exercises

### 9. User saves the flow
Once the flow is complete and validated, the user saves it into the app and can begin using it for training.

## Supporting Product Logic

### Normalization-first design
The recommended import path is:

Copy prompt from app -> paste prompt into chatbot -> chatbot normalizes flow -> paste normalized flow into app -> app validates and imports

This improves parsing reliability and reduces ambiguity before the app handles the flow.

### Ordered flow structure
The flow should be stored as an ordered list of exercises, and each flow exercise can own multiple set rows when needed.

### User control over AI assumptions
AI can help normalize text and suggest missing values, but the user should remain in control. Whenever the model generates missing information, the UI should make that explicit.

## MVP Scope

1. Provide a copyable normalization prompt
2. Accept normalized workout text input
3. Parse flow data into internal structure
4. Detect missing required fields
5. Let the user fill them manually or accept AI suggestions
6. Resolve exercises against canonical exercise records
7. Review and save the flow

## Summary

The app’s workflow should reduce friction between AI-generated workout advice and real execution.

The product value is not just workout tracking and not just AI chat. The value is helping users quickly convert rough workout plans into reliable, structured flows they can immediately use.
