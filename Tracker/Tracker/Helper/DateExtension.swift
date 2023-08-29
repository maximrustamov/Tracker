import UIKit

extension Date {
    var yearMonthDayComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
