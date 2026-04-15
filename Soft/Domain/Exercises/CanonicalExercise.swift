import Foundation

struct CanonicalExercise: Identifiable, Hashable {
    let key: String
    let name: String
    let aliases: [String]
    let equipment: [CanonicalEquipment]
    let primaryFocus: CanonicalBodyPart
    let focus: [CanonicalBodyPart]
    let notes: String?
    let instructions: String?
    let imageAssetName: String?

    init(
        key: String,
        name: String,
        aliases: [String],
        equipment: [CanonicalEquipment],
        primaryFocus: CanonicalBodyPart,
        focus: [CanonicalBodyPart],
        notes: String?,
        instructions: String?,
        imageAssetName: String? = nil
    ) {
        self.key = key
        self.name = name
        self.aliases = aliases
        self.equipment = equipment
        self.primaryFocus = primaryFocus
        self.focus = Self.normalizedFocus(primaryFocus: primaryFocus, focus: focus)
        self.notes = notes
        self.instructions = instructions
        self.imageAssetName = imageAssetName
    }

    var id: String { key }

    private static func normalizedFocus(
        primaryFocus: CanonicalBodyPart,
        focus: [CanonicalBodyPart]
    ) -> [CanonicalBodyPart] {
        [primaryFocus] + focus.filter { $0 != primaryFocus }
    }
}
