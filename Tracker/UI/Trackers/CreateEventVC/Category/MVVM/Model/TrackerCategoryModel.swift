import UIKit

struct TrackerCategoryModel: Hashable {
    let name: String
    let trackers: [Tracker]
    
    func visibleTrackers(filterString: String, pin: Bool?) -> [Tracker] {
        if filterString.isEmpty {
            return pin == nil ? trackers : trackers.filter { $0.pinned == pin }
        } else {
            return pin == nil ? trackers
                .filter { $0.name.lowercased().contains(filterString.lowercased()) }
            : trackers
                .filter { $0.name.lowercased().contains(filterString.lowercased()) }
                .filter { $0.pinned == pin }
                
        }
    }
}

