import Foundation

enum CanonicalEquipment: String, CaseIterable, Identifiable, Hashable {
    case barbell
    case bench
    case bodyweight
    case cable
    case dipBars = "dip-bars"
    case dumbbell
    case inclineBench = "incline-bench"
    case kettlebell
    case machine
    case pullUpBar = "pull-up-bar"
    case rack
    case ropeAttachment = "rope-attachment"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .barbell:
            return "Barbell"
        case .bench:
            return "Bench"
        case .bodyweight:
            return "Bodyweight"
        case .cable:
            return "Cable"
        case .dipBars:
            return "Dip Bars"
        case .dumbbell:
            return "Dumbbell"
        case .inclineBench:
            return "Incline Bench"
        case .kettlebell:
            return "Kettlebell"
        case .machine:
            return "Machine"
        case .pullUpBar:
            return "Pull-Up Bar"
        case .rack:
            return "Rack"
        case .ropeAttachment:
            return "Rope Attachment"
        }
    }
}
