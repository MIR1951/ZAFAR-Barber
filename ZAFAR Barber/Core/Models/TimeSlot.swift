import Foundation

struct TimeSlot: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var isAvailable: Bool = true
} 