import Foundation

struct CanonicalExercise: Identifiable, Hashable {
    let key: String
    let name: String
    let aliases: [String]
    let equipment: [String]
    let notes: String?
    let instructions: String?

    var id: String { key }

    func matches(_ rawName: String) -> Bool {
        let normalizedRawName = Self.normalize(rawName)

        if Self.normalize(name) == normalizedRawName {
            return true
        }

        return aliases.contains { Self.normalize($0) == normalizedRawName }
    }

    static func normalize(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum CanonicalExerciseCatalog {
    static let all: [CanonicalExercise] = [
        CanonicalExercise(
            key: "bench-press-barbell",
            name: "Bench Press (Barbell)",
            aliases: ["Barbell Bench Press", "Bench Press"],
            equipment: ["barbell", "bench"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "squat-barbell",
            name: "Squat (Barbell)",
            aliases: ["Barbell Squat", "Back Squat"],
            equipment: ["barbell", "rack"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "deadlift-barbell",
            name: "Deadlift (Barbell)",
            aliases: ["Barbell Deadlift", "Conventional Deadlift"],
            equipment: ["barbell"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "overhead-press-barbell",
            name: "Overhead Press (Barbell)",
            aliases: ["Barbell Overhead Press", "Shoulder Press (Barbell)", "OHP"],
            equipment: ["barbell"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "bent-over-row-barbell",
            name: "Bent Over Row (Barbell)",
            aliases: ["Barbell Row", "Barbell Bent-Over Row"],
            equipment: ["barbell"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "pull-up",
            name: "Pull Up",
            aliases: ["Pull-Up", "Pullup"],
            equipment: ["pull-up bar"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "lat-pulldown-cable",
            name: "Lat Pulldown (Cable)",
            aliases: ["Cable Lat Pulldown", "Lat Pulldown"],
            equipment: ["cable"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "bench-press-dumbbell",
            name: "Bench Press (Dumbbell)",
            aliases: ["Dumbbell Bench Press", "DB Bench Press"],
            equipment: ["dumbbells", "bench"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "incline-bench-press-barbell",
            name: "Incline Bench Press (Barbell)",
            aliases: ["Barbell Incline Bench Press", "Incline Barbell Press"],
            equipment: ["barbell", "incline bench"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "incline-bench-press-dumbbell",
            name: "Incline Bench Press (Dumbbell)",
            aliases: ["Dumbbell Incline Bench Press", "Incline Dumbbell Press"],
            equipment: ["dumbbells", "incline bench"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "romanian-deadlift-barbell",
            name: "Romanian Deadlift (Barbell)",
            aliases: ["Barbell Romanian Deadlift", "RDL", "Barbell RDL"],
            equipment: ["barbell"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "leg-press-machine",
            name: "Leg Press (Machine)",
            aliases: ["Machine Leg Press", "Leg Press"],
            equipment: ["machine"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "hip-thrust-barbell",
            name: "Hip Thrust (Barbell)",
            aliases: ["Barbell Hip Thrust"],
            equipment: ["barbell", "bench"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "goblet-squat",
            name: "Goblet Squat",
            aliases: ["Goblet Squat (Dumbbell)", "Goblet Squat (Kettlebell)"],
            equipment: ["dumbbell", "kettlebell"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "reverse-lunge",
            name: "Reverse Lunge",
            aliases: ["Reverse Lunge (Barbell)", "Reverse Lunge (Dumbbell)"],
            equipment: ["barbell", "dumbbells"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "lateral-raise-dumbbell",
            name: "Lateral Raise (Dumbbell)",
            aliases: ["Dumbbell Lateral Raise", "Side Lateral Raise"],
            equipment: ["dumbbells"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "bicep-curl-barbell",
            name: "Bicep Curl (Barbell)",
            aliases: ["Barbell Curl", "Barbell Biceps Curl"],
            equipment: ["barbell"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "hammer-curl-dumbbell",
            name: "Hammer Curl (Dumbbell)",
            aliases: ["Dumbbell Hammer Curl"],
            equipment: ["dumbbells"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "triceps-rope-pushdown",
            name: "Triceps Rope Pushdown",
            aliases: ["Rope Pushdown", "Cable Rope Pushdown", "Tricep Rope Pushdown"],
            equipment: ["cable", "rope attachment"],
            notes: nil,
            instructions: nil
        ),
        CanonicalExercise(
            key: "chest-dip",
            name: "Chest Dip",
            aliases: ["Dip", "Chest Dip (Bodyweight)"],
            equipment: ["dip bars"],
            notes: nil,
            instructions: nil
        ),
    ]

    static let byKey = Dictionary(uniqueKeysWithValues: all.map { ($0.key, $0) })

    static func match(name: String) -> CanonicalExercise? {
        all.first { $0.matches(name) }
    }
}
