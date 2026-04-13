# Workout App High-Level Workflow

## Goal

Help users turn messy workout ideas or chatbot-generated routines into clean, structured, editable routines inside the app with minimal friction.

## Core Principle

The app should hide technical implementation details from most users. The experience should feel like guided routine import, not manual data entry or developer tooling.

## High-Level Workflow

### 1. User plans their workout outside the app
The user talks with a chatbot about their goals, health condition, schedule, equipment, and exercise preferences. The chatbot produces a draft routine, but that routine is often incomplete, inconsistent, or not structured enough for direct import.

### 2. App provides a normalization prompt
The app gives the user a reusable prompt template. The user copies this prompt into their chatbot so the chatbot can rewrite the routine into a more predictable format.

The normalized routine should include the key workout fields the app needs, such as:
- exercise type
- sets
- reps
- duration
- rest time
- notes
- other relevant exercise-specific information

This step is called refinement or normalization.

### 3. User pastes the normalized routine into the app
After the chatbot rewrites the routine into the expected format, the user pastes the result back into the app.

### 4. App parses the routine into structured internal data
The app reads the pasted routine and converts it into the app’s internal workout structure.

At this stage, the app should:
- identify routine sections and exercises
- extract exercise fields
- classify exercise type
- prepare data for validation and saving

### 5. App validates the imported routine
The app checks whether each exercise has the required information.

Examples of potentially required information include:
- exercise identity
- sets
- reps for rep-based exercises
- duration for timed exercises

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
Use this when the missing fields can reasonably be generated based on exercise type, routine context, and training goal.

These generated values should be clearly presented as suggestions, not facts.

### 7. App resolves exercises to canonical records
Exercise names from chatbot output may vary. The app should map imported exercise names to canonical exercises in the app database.

This may use:
- alias mapping
- fuzzy matching
- fallback selection or creation flow

The goal is to make sure imported routines connect to the correct exercise records for tracking, media, and analytics.

### 8. User reviews and edits the routine
Before saving, the app presents the structured result in a clean review screen.

The user should be able to:
- confirm parsed exercises
- edit fields
- accept or reject AI-generated suggestions
- resolve unmatched exercises

### 9. User saves the routine
Once the routine is complete and validated, the user saves it into the app and can begin using it for training.

## Supporting Product Logic

### Normalization-first design
The recommended import path is:

Copy prompt from app -> paste prompt into chatbot -> chatbot normalizes routine -> paste normalized routine into app -> app validates and imports

This improves parsing reliability and reduces ambiguity before the app handles the routine.

### Exercise-aware requirements
Different exercise types need different fields. The import flow should reflect this.

Examples:
- strength exercise: sets, reps, rest
- cardio exercise: duration or distance
- isometric exercise: sets, hold duration
- mobility exercise: duration, side, rounds

The app should not force the exact same required fields for every exercise.

### User control over AI assumptions
AI can help normalize text and suggest missing values, but the user should remain in control. Whenever the model generates missing information, the UI should make that explicit.

## MVP Scope

1. Provide a copyable normalization prompt
2. Accept normalized workout text input
3. Parse routine data into internal structure
4. Detect missing required fields
5. Let the user fill them manually or accept AI suggestions
6. Resolve exercises against canonical exercise records
7. Review and save the routine

## Summary

The app’s workflow should reduce friction between AI-generated workout advice and real execution.

The product value is not just workout tracking and not just AI chat. The value is helping users quickly convert rough workout plans into reliable, structured routines they can immediately use.

