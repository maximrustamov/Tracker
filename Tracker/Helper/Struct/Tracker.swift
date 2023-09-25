import UIKit

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let color: UIColor?
    let emoji: String?
    let schedule: [WeekDay]?
    let pinned: Bool?
    var category: TrackerCategoryModel? {
        return TrackerCategoryStore().category(forTracker: self)
    }
}
