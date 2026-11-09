import SwiftUI

/// A kind of notification people can opt in to in the preview flow.
enum PreviewNotification: CaseIterable, Hashable {
    case classReminders, waitlistUpdates, scheduleChanges

    var title: String {
        switch self {
        case .classReminders: "Class reminders"
        case .waitlistUpdates: "Waitlist updates"
        case .scheduleChanges: "Schedule changes"
        }
    }

    var detail: String {
        switch self {
        case .classReminders: "An hour before a class you've booked."
        case .waitlistUpdates: "When a spot opens up in a full class."
        case .scheduleChanges: "When a class is moved, cancelled, or gets a new instructor."
        }
    }

    var systemImage: String {
        switch self {
        case .classReminders: "calendar"
        case .waitlistUpdates: "person.2"
        case .scheduleChanges: "arrow.triangle.2.circlepath"
        }
    }
}
