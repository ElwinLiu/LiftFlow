export type ExerciseType = "strength" | "cardio" | "isometric" | "mobility";

export interface ExerciseDraft {
  name: string;
  exerciseType: ExerciseType;
  sets?: number;
  reps?: number;
  durationSeconds?: number;
  restSeconds?: number;
  distanceValue?: number;
  distanceUnit?: string;
  side?: string;
  rounds?: number;
  notes?: string;
}

export interface RoutineSectionDraft {
  title: string;
  exercises: ExerciseDraft[];
}

export interface ImportDraft {
  title: string;
  goal?: string;
  sections: RoutineSectionDraft[];
}

export interface ValidationIssue {
  sectionTitle: string;
  exerciseName: string;
  field: keyof ExerciseDraft;
  reason: "missing_required" | "unresolved_exercise";
}

export interface CanonicalExercise {
  id: string;
  name: string;
  exerciseType: ExerciseType;
  aliases: string[];
}

export interface ResolvedExercise {
  originalName: string;
  canonicalExerciseId?: string;
  canonicalName?: string;
  confidence: number;
  status: "resolved" | "candidate" | "unmatched";
  candidates: Array<{
    canonicalExerciseId: string;
    canonicalName: string;
    confidence: number;
  }>;
}

export interface Suggestion {
  exerciseName: string;
  field: keyof ExerciseDraft;
  value: string | number;
  source: "rule";
}

export interface FinalizedRoutine {
  id: string;
  title: string;
  goal?: string;
  sections: RoutineSectionDraft[];
}
