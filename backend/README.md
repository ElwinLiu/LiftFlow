# LiftFlow Backend

This folder contains the backend domain logic for LiftFlow's routine import flow.

## Commands

- `npm test` runs the backend test suite
- `npm run typecheck` runs TypeScript type-checking

## Current Coverage

The tests cover the MVP import path:

- parse normalized workout text into a routine draft
- validate required fields by exercise type
- resolve imported exercise names against canonical exercises and aliases
- suggest safe default values without inventing unsafe required ones
- reject invalid saves
- finalize valid routines

## Main Files

- `src/importFlow.ts` contains the import-flow logic
- `tests/importFlow.test.ts` contains the test scenarios driving the behavior
