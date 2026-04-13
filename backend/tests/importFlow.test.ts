import {
  finalizeRoutine,
  parseNormalizedRoutine,
  resolveExercises,
  suggestMissingFields,
  validateRoutineDraft,
} from "../src/index.js";
import type { CanonicalExercise } from "../src/types.js";
import { describe, expect, it } from "vitest";

const rawRoutine = `
Routine: Upper Body Builder
Goal: Build upper body strength

## Warm-Up
- Jump Rope | type=cardio | duration=300s

## Main
- DB Bench Press | type=strength | sets=4 | reps=8 | rest=90s
- Plank | type=isometric | sets=3 | duration=45s
- Running | type=cardio
- Shoulder Mobility | type=mobility | rounds=2
`.trim();

const canonicalExercises: CanonicalExercise[] = [
  {
    id: "ex-db-bench",
    name: "Dumbbell Bench Press",
    exerciseType: "strength",
    aliases: ["DB Bench Press", "Dumbbell Bench"],
  },
  {
    id: "ex-jump-rope",
    name: "Jump Rope",
    exerciseType: "cardio",
    aliases: ["Skipping Rope"],
  },
  {
    id: "ex-plank",
    name: "Plank",
    exerciseType: "isometric",
    aliases: [],
  },
  {
    id: "ex-running",
    name: "Running",
    exerciseType: "cardio",
    aliases: ["Run"],
  },
  {
    id: "ex-shoulder-mobility",
    name: "Shoulder Mobility",
    exerciseType: "mobility",
    aliases: ["Shoulder Openers"],
  },
];

describe("LiftFlow import flow", () => {
  it("parses normalized workout text into a structured draft", () => {
    const draft = parseNormalizedRoutine(rawRoutine);

    expect(draft.title).toBe("Upper Body Builder");
    expect(draft.goal).toBe("Build upper body strength");
    expect(draft.sections).toHaveLength(2);
    expect(draft.sections[0]?.title).toBe("Warm-Up");
    expect(draft.sections[1]?.exercises[0]).toMatchObject({
      name: "DB Bench Press",
      exerciseType: "strength",
      sets: 4,
      reps: 8,
      restSeconds: 90,
    });
  });

  it("detects required fields based on exercise type", () => {
    const draft = parseNormalizedRoutine(rawRoutine);

    expect(validateRoutineDraft(draft)).toEqual([
      {
        sectionTitle: "Main",
        exerciseName: "Running",
        field: "durationSeconds",
        reason: "missing_required",
      },
    ]);
  });

  it("resolves imported exercise names against canonical exercises and aliases", () => {
    const draft = parseNormalizedRoutine(rawRoutine);
    const resolutions = resolveExercises(draft, canonicalExercises);

    expect(resolutions).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          originalName: "DB Bench Press",
          canonicalExerciseId: "ex-db-bench",
          canonicalName: "Dumbbell Bench Press",
          status: "resolved",
        }),
        expect.objectContaining({
          originalName: "Running",
          canonicalExerciseId: "ex-running",
          status: "resolved",
        }),
      ]),
    );
  });

  it("suggests safe values without inventing unsafe required ones", () => {
    const draft = parseNormalizedRoutine(rawRoutine);
    const issues = validateRoutineDraft(draft);

    expect(suggestMissingFields(draft, issues)).toEqual([
      {
        exerciseName: "Shoulder Mobility",
        field: "side",
        value: "both",
        source: "rule",
      },
    ]);
  });

  it("rejects finalization when required fields are still missing", () => {
    const draft = parseNormalizedRoutine(rawRoutine);
    const issues = validateRoutineDraft(draft);
    const resolutions = resolveExercises(draft, canonicalExercises);

    expect(() => finalizeRoutine(draft, issues, resolutions)).toThrow(
      "Routine draft is not ready to save",
    );
  });

  it("finalizes a valid routine once issues are resolved", () => {
    const draft = parseNormalizedRoutine(
      rawRoutine.replace("- Running | type=cardio", "- Running | type=cardio | duration=1200s"),
    );
    const issues = validateRoutineDraft(draft);
    const resolutions = resolveExercises(draft, canonicalExercises);

    const saved = finalizeRoutine(draft, issues, resolutions);

    expect(issues).toEqual([]);
    expect(saved.id).toMatch(/^routine_/);
    expect(saved.sections[1]?.exercises).toHaveLength(4);
  });
});
