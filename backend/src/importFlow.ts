import type {
  CanonicalExercise,
  FinalizedRoutine,
  ExerciseDraft,
  ImportDraft,
  ResolvedExercise,
  Suggestion,
  ValidationIssue,
} from "./types.js";

const FIELD_PARSERS: Record<string, (exercise: ExerciseDraft, value: string) => void> = {
  duration: (exercise, value) => {
    exercise.durationSeconds = parseDurationSeconds(value);
  },
  distance: (exercise, value) => {
    const match = value.trim().match(/^(\d+(?:\.\d+)?)([a-zA-Z]+)$/);

    if (!match) {
      return;
    }

    exercise.distanceValue = Number(match[1]);
    exercise.distanceUnit = match[2]?.toLowerCase();
  },
  notes: (exercise, value) => {
    exercise.notes = value.trim();
  },
  reps: (exercise, value) => {
    exercise.reps = parseInteger(value);
  },
  rest: (exercise, value) => {
    exercise.restSeconds = parseDurationSeconds(value);
  },
  rounds: (exercise, value) => {
    exercise.rounds = parseInteger(value);
  },
  sets: (exercise, value) => {
    exercise.sets = parseInteger(value);
  },
  side: (exercise, value) => {
    exercise.side = value.trim().toLowerCase();
  },
  type: (exercise, value) => {
    exercise.exerciseType = value.trim().toLowerCase() as ExerciseDraft["exerciseType"];
  },
};

export function parseNormalizedRoutine(rawText: string): ImportDraft {
  const lines = rawText
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0);

  const draft: ImportDraft = {
    title: "",
    sections: [],
  };

  let currentSection: ImportDraft["sections"][number] | undefined;

  for (const line of lines) {
    if (line.startsWith("Routine:")) {
      draft.title = line.slice("Routine:".length).trim();
      continue;
    }

    if (line.startsWith("Goal:")) {
      draft.goal = line.slice("Goal:".length).trim();
      continue;
    }

    if (line.startsWith("## ")) {
      currentSection = {
        title: line.slice(3).trim(),
        exercises: [],
      };
      draft.sections.push(currentSection);
      continue;
    }

    if (line.startsWith("- ")) {
      if (!currentSection) {
        throw new Error("Exercise encountered before any section");
      }

      currentSection.exercises.push(parseExerciseLine(line));
    }
  }

  if (!draft.title) {
    throw new Error("Routine title is required");
  }

  return draft;
}

export function validateRoutineDraft(draft: ImportDraft): ValidationIssue[] {
  const issues: ValidationIssue[] = [];

  for (const section of draft.sections) {
    for (const exercise of section.exercises) {
      if (exercise.exerciseType === "strength") {
        if (exercise.sets == null) {
          issues.push(missingRequired(section.title, exercise.name, "sets"));
        }
        if (exercise.reps == null) {
          issues.push(missingRequired(section.title, exercise.name, "reps"));
        }
      }

      if (exercise.exerciseType === "cardio") {
        if (exercise.durationSeconds == null && exercise.distanceValue == null) {
          issues.push(missingRequired(section.title, exercise.name, "durationSeconds"));
        }
      }

      if (exercise.exerciseType === "isometric") {
        if (exercise.sets == null) {
          issues.push(missingRequired(section.title, exercise.name, "sets"));
        }
        if (exercise.durationSeconds == null) {
          issues.push(missingRequired(section.title, exercise.name, "durationSeconds"));
        }
      }

      if (exercise.exerciseType === "mobility") {
        if (exercise.durationSeconds == null && exercise.rounds == null) {
          issues.push(missingRequired(section.title, exercise.name, "durationSeconds"));
        }
      }
    }
  }

  return issues;
}

export function resolveExercises(
  draft: ImportDraft,
  canonicalExercises: CanonicalExercise[],
): ResolvedExercise[] {
  return draft.sections.flatMap((section) =>
    section.exercises.map((exercise) => resolveExercise(exercise.name, canonicalExercises)),
  );
}

export function suggestMissingFields(
  draft: ImportDraft,
  _issues: ValidationIssue[],
): Suggestion[] {
  const suggestions: Suggestion[] = [];

  for (const section of draft.sections) {
    for (const exercise of section.exercises) {
      if (exercise.exerciseType === "mobility" && !exercise.side) {
        suggestions.push({
          exerciseName: exercise.name,
          field: "side",
          value: "both",
          source: "rule",
        });
      }
    }
  }

  return suggestions;
}

export function finalizeRoutine(
  draft: ImportDraft,
  issues: ValidationIssue[],
  resolutions: ResolvedExercise[],
): FinalizedRoutine {
  const hasUnresolvedExercise = resolutions.some((resolution) => resolution.status !== "resolved");

  if (issues.length > 0 || hasUnresolvedExercise) {
    throw new Error("Routine draft is not ready to save");
  }

  return {
    id: `routine_${Date.now()}`,
    title: draft.title,
    goal: draft.goal,
    sections: draft.sections,
  };
}

function parseExerciseLine(line: string): ExerciseDraft {
  const segments = line.slice(2).split("|").map((part) => part.trim());
  const [name, ...fields] = segments;

  if (!name) {
    throw new Error("Exercise name is required");
  }

  const exercise: ExerciseDraft = {
    name,
    exerciseType: "strength",
  };

  for (const field of fields) {
    const [rawKey, ...rawValueParts] = field.split("=");
    const key = rawKey?.trim().toLowerCase();
    const value = rawValueParts.join("=").trim();

    if (!key || !value) {
      continue;
    }

    FIELD_PARSERS[key]?.(exercise, value);
  }

  return exercise;
}

function parseInteger(value: string): number {
  return Number.parseInt(value.trim(), 10);
}

function parseDurationSeconds(value: string): number {
  const trimmed = value.trim().toLowerCase();

  if (trimmed.endsWith("s")) {
    return Number.parseInt(trimmed.slice(0, -1), 10);
  }

  if (trimmed.endsWith("m")) {
    return Number.parseInt(trimmed.slice(0, -1), 10) * 60;
  }

  return Number.parseInt(trimmed, 10);
}

function missingRequired(
  sectionTitle: string,
  exerciseName: string,
  field: keyof ExerciseDraft,
): ValidationIssue {
  return {
    sectionTitle,
    exerciseName,
    field,
    reason: "missing_required",
  };
}

function resolveExercise(
  originalName: string,
  canonicalExercises: CanonicalExercise[],
): ResolvedExercise {
  const normalizedOriginal = normalizeText(originalName);
  const scoredMatches = canonicalExercises
    .map((exercise) => ({
      exercise,
      confidence: scoreExerciseMatch(normalizedOriginal, exercise),
    }))
    .sort((left, right) => right.confidence - left.confidence);

  const topMatch = scoredMatches[0];

  if (!topMatch || topMatch.confidence < 0.65) {
    return {
      originalName,
      confidence: topMatch?.confidence ?? 0,
      status: "unmatched",
      candidates: [],
    };
  }

  if (topMatch.confidence >= 0.86) {
    return {
      originalName,
      canonicalExerciseId: topMatch.exercise.id,
      canonicalName: topMatch.exercise.name,
      confidence: topMatch.confidence,
      status: "resolved",
      candidates: [],
    };
  }

  return {
    originalName,
    confidence: topMatch.confidence,
    status: "candidate",
    candidates: scoredMatches.slice(0, 3).map(({ exercise, confidence }) => ({
      canonicalExerciseId: exercise.id,
      canonicalName: exercise.name,
      confidence,
    })),
  };
}

function scoreExerciseMatch(normalizedOriginal: string, exercise: CanonicalExercise): number {
  const canonical = normalizeText(exercise.name);

  if (normalizedOriginal === canonical) {
    return 1;
  }

  for (const alias of exercise.aliases) {
    if (normalizedOriginal === normalizeText(alias)) {
      return 0.99;
    }
  }

  let bestScore = similarity(normalizedOriginal, canonical);

  for (const alias of exercise.aliases) {
    bestScore = Math.max(bestScore, similarity(normalizedOriginal, normalizeText(alias)));
  }

  return bestScore;
}

function normalizeText(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function similarity(left: string, right: string): number {
  if (!left || !right) {
    return 0;
  }

  const distance = levenshtein(left, right);
  const maxLength = Math.max(left.length, right.length);

  return maxLength === 0 ? 1 : 1 - distance / maxLength;
}

function levenshtein(left: string, right: string): number {
  const rows = left.length + 1;
  const cols = right.length + 1;
  const matrix = Array.from({ length: rows }, () => Array<number>(cols).fill(0));

  for (let row = 0; row < rows; row += 1) {
    matrix[row]![0] = row;
  }

  for (let col = 0; col < cols; col += 1) {
    matrix[0]![col] = col;
  }

  for (let row = 1; row < rows; row += 1) {
    for (let col = 1; col < cols; col += 1) {
      const cost = left[row - 1] === right[col - 1] ? 0 : 1;
      matrix[row]![col] = Math.min(
        matrix[row - 1]![col]! + 1,
        matrix[row]![col - 1]! + 1,
        matrix[row - 1]![col - 1]! + cost,
      );
    }
  }

  return matrix[rows - 1]![cols - 1]!;
}
