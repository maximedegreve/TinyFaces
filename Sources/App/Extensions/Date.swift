import Vapor

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
