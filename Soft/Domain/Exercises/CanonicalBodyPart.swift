import Foundation

enum CanonicalBodyPart: String, CaseIterable, Identifiable, Hashable {
    case back
    case biceps
    case calves
    case chest
    case core
    case forearms
    case glutes
    case hamstrings
    case quads
    case shoulders
    case triceps

    var id: String { rawValue }

    var name: String {
        switch self {
        case .back:
            return "Back"
        case .biceps:
            return "Biceps"
        case .calves:
            return "Calves"
        case .chest:
            return "Chest"
        case .core:
            return "Core"
        case .forearms:
            return "Forearms"
        case .glutes:
            return "Glutes"
        case .hamstrings:
            return "Hamstrings"
        case .quads:
            return "Quads"
        case .shoulders:
            return "Shoulders"
        case .triceps:
            return "Triceps"
        }
    }
}
