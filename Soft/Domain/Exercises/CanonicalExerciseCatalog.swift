import Foundation

enum CanonicalExerciseCatalog {
    static let all: [CanonicalExercise] = [
        CanonicalExercise(
            key: "back-squat",
            name: "Back Squat",
            aliases: ["Squat (Barbell)", "Barbell Squat", "Back Squat"],
            equipment: [.barbell, .rack],
            primaryFocus: .quads,
            focus: [.quads, .glutes, .hamstrings, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "goblet-squat",
            name: "Goblet Squat",
            aliases: ["Goblet Squat (Dumbbell)", "Goblet Squat (Kettlebell)"],
            equipment: [.dumbbell, .kettlebell],
            primaryFocus: .quads,
            focus: [.quads, .glutes, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "leg-press",
            name: "Leg Press",
            aliases: ["Leg Press (Machine)", "Machine Leg Press"],
            equipment: [.machine],
            primaryFocus: .quads,
            focus: [.quads, .glutes, .hamstrings],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "bodyweight-squat",
            name: "Bodyweight Squat",
            aliases: ["Air Squat"],
            equipment: [.bodyweight],
            primaryFocus: .quads,
            focus: [.quads, .glutes, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "forward-lunge",
            name: "Forward Lunge",
            aliases: ["Lunge", "Bodyweight Forward Lunge"],
            equipment: [.bodyweight],
            primaryFocus: .quads,
            focus: [.quads, .glutes, .hamstrings, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "reverse-lunge",
            name: "Reverse Lunge",
            aliases: ["Reverse Lunge (Barbell)", "Reverse Lunge (Dumbbell)"],
            equipment: [.bodyweight, .barbell, .dumbbell],
            primaryFocus: .quads,
            focus: [.quads, .glutes, .hamstrings, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "leg-extension",
            name: "Leg Extension",
            aliases: ["Machine Leg Extension"],
            equipment: [.machine],
            primaryFocus: .quads,
            focus: [.quads],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "leg-curl",
            name: "Leg Curl",
            aliases: ["Machine Leg Curl", "Hamstring Curl"],
            equipment: [.machine],
            primaryFocus: .hamstrings,
            focus: [.hamstrings],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "standing-calf-raise",
            name: "Standing Calf Raise",
            aliases: ["Machine Standing Calf Raise"],
            equipment: [.machine],
            primaryFocus: .calves,
            focus: [.calves],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "conventional-deadlift",
            name: "Conventional Deadlift",
            aliases: ["Deadlift (Barbell)", "Barbell Deadlift", "Deadlift"],
            equipment: [.barbell],
            primaryFocus: .glutes,
            focus: [.glutes, .back, .hamstrings, .forearms, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "romanian-deadlift",
            name: "Romanian Deadlift",
            aliases: ["Romanian Deadlift (Barbell)", "Barbell Romanian Deadlift", "RDL", "Barbell RDL"],
            equipment: [.barbell],
            primaryFocus: .hamstrings,
            focus: [.hamstrings, .glutes, .back, .forearms, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "hip-thrust",
            name: "Hip Thrust",
            aliases: ["Hip Thrust (Barbell)", "Barbell Hip Thrust"],
            equipment: [.barbell, .bench],
            primaryFocus: .glutes,
            focus: [.glutes, .hamstrings, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "bench-press",
            name: "Bench Press",
            aliases: ["Bench Press (Barbell)", "Barbell Bench Press"],
            equipment: [.barbell, .bench],
            primaryFocus: .chest,
            focus: [.chest, .shoulders, .triceps],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "dumbbell-bench-press",
            name: "Dumbbell Bench Press",
            aliases: ["Bench Press (Dumbbell)", "DB Bench Press"],
            equipment: [.dumbbell, .bench],
            primaryFocus: .chest,
            focus: [.chest, .shoulders, .triceps],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "incline-bench-press-barbell",
            name: "Incline Bench Press (Barbell)",
            aliases: ["Barbell Incline Bench Press", "Incline Barbell Press"],
            equipment: [.barbell, .inclineBench],
            primaryFocus: .chest,
            focus: [.chest, .shoulders, .triceps],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "incline-dumbbell-bench-press",
            name: "Incline Dumbbell Bench Press",
            aliases: ["Incline Bench Press (Dumbbell)", "Dumbbell Incline Bench Press", "Incline Dumbbell Press"],
            equipment: [.dumbbell, .inclineBench],
            primaryFocus: .chest,
            focus: [.chest, .shoulders, .triceps],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "machine-chest-press",
            name: "Machine Chest Press",
            aliases: ["Chest Press (Machine)", "Machine Press"],
            equipment: [.machine],
            primaryFocus: .chest,
            focus: [.chest, .shoulders, .triceps],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "push-up",
            name: "Push-Up",
            aliases: ["Push Up"],
            equipment: [.bodyweight],
            primaryFocus: .chest,
            focus: [.chest, .shoulders, .triceps, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "parallel-bar-dip",
            name: "Parallel Bar Dip",
            aliases: ["Chest Dip", "Dip", "Chest Dip (Bodyweight)"],
            equipment: [.bodyweight, .dipBars],
            primaryFocus: .triceps,
            focus: [.triceps, .chest, .shoulders],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "overhead-press",
            name: "Overhead Press",
            aliases: ["Overhead Press (Barbell)", "Barbell Overhead Press", "Shoulder Press (Barbell)", "OHP"],
            equipment: [.barbell],
            primaryFocus: .shoulders,
            focus: [.shoulders, .triceps, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "dumbbell-shoulder-press",
            name: "Dumbbell Shoulder Press",
            aliases: ["Seated Dumbbell Shoulder Press", "Dumbbell Overhead Press"],
            equipment: [.dumbbell, .bench],
            primaryFocus: .shoulders,
            focus: [.shoulders, .triceps, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "lateral-raise",
            name: "Lateral Raise",
            aliases: ["Lateral Raise (Dumbbell)", "Dumbbell Lateral Raise", "Side Lateral Raise"],
            equipment: [.dumbbell],
            primaryFocus: .shoulders,
            focus: [.shoulders],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "barbell-row",
            name: "Barbell Row",
            aliases: ["Bent Over Row (Barbell)", "Barbell Bent-Over Row", "Bent Over Row"],
            equipment: [.barbell],
            primaryFocus: .back,
            focus: [.back, .biceps, .shoulders, .forearms],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "one-arm-dumbbell-row",
            name: "One-Arm Dumbbell Row",
            aliases: ["Single-Arm Dumbbell Row", "Dumbbell Row"],
            equipment: [.dumbbell, .bench],
            primaryFocus: .back,
            focus: [.back, .biceps, .forearms, .core],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "seated-cable-row",
            name: "Seated Cable Row",
            aliases: ["Cable Row", "Seated Row"],
            equipment: [.cable],
            primaryFocus: .back,
            focus: [.back, .biceps, .forearms],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "face-pull",
            name: "Face Pull",
            aliases: ["Cable Face Pull"],
            equipment: [.cable, .ropeAttachment],
            primaryFocus: .shoulders,
            focus: [.shoulders, .back],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "pull-up",
            name: "Pull-Up",
            aliases: ["Pull Up", "Pullup"],
            equipment: [.bodyweight, .pullUpBar],
            primaryFocus: .back,
            focus: [.back, .biceps, .forearms],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "chin-up",
            name: "Chin-Up",
            aliases: ["Chin Up", "Supinated Pull-Up"],
            equipment: [.bodyweight, .pullUpBar],
            primaryFocus: .back,
            focus: [.back, .biceps, .forearms],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "lat-pulldown",
            name: "Lat Pulldown",
            aliases: ["Lat Pulldown (Cable)", "Cable Lat Pulldown"],
            equipment: [.cable],
            primaryFocus: .back,
            focus: [.back, .biceps, .forearms, .shoulders],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "barbell-curl",
            name: "Barbell Curl",
            aliases: ["Bicep Curl (Barbell)", "Barbell Biceps Curl"],
            equipment: [.barbell],
            primaryFocus: .biceps,
            focus: [.biceps, .forearms],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "dumbbell-curl",
            name: "Dumbbell Curl",
            aliases: ["Alternating Dumbbell Curl"],
            equipment: [.dumbbell],
            primaryFocus: .biceps,
            focus: [.biceps, .forearms],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "hammer-curl",
            name: "Hammer Curl",
            aliases: ["Hammer Curl (Dumbbell)", "Dumbbell Hammer Curl"],
            equipment: [.dumbbell],
            primaryFocus: .biceps,
            focus: [.biceps, .forearms],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "triceps-pushdown",
            name: "Triceps Pushdown",
            aliases: ["Triceps Rope Pushdown", "Rope Pushdown", "Cable Rope Pushdown", "Tricep Rope Pushdown"],
            equipment: [.cable, .ropeAttachment],
            primaryFocus: .triceps,
            focus: [.triceps],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "forearm-plank",
            name: "Forearm Plank",
            aliases: ["Plank"],
            equipment: [.bodyweight],
            primaryFocus: .core,
            focus: [.core, .shoulders, .glutes],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "hanging-leg-raise",
            name: "Hanging Leg Raise",
            aliases: ["Leg Raise", "Hanging Knee Raise"],
            equipment: [.bodyweight, .pullUpBar],
            primaryFocus: .core,
            focus: [.core, .forearms, .shoulders],
            notes: nil,
            instructions: nil
        ),
    ]
}
