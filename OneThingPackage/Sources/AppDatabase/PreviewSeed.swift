import AppModels
import Dependencies
import DependenciesMacros
import Foundation

#if DEBUG

extension AppData {
  public static var previewSeed: Self {
    @Dependency(\.date) var date
    let calendar = Calendar.current
    return AppData {
      TodoListData(
        name: "Big Ideas",
        color: .yellow
      )
      TodoListData(
        name: "Career Goals",
        color: .red,
        todos: {
          TodoData(
            title: "Update résumé",
            notes: "Add iOS projects",
            deadline: calendar.date( // Next Friday at 4:00 PM
              bySettingHour: 16,
              minute: 0,
              second: 0,
              of: calendar.nextDate(
                after: .now,
                matching: DateComponents(weekday: 6),
                matchingPolicy: .nextTime)!)!
          )
          TodoData(
            title: "Learn SwiftUI animations",
            notes: "Start with matchedGeometryEffect",
            deleteDate: date.now
          )
        }
      )
      TodoListData(
        name: "Daily Grind",
        color: .blue,
      )
      TodoListData(
        name: "Declutter",
        color: .cyan,
        todos: {
          TodoData(
            title: "Organize photo library",
            notes: "Sort into yearly folders"
          )
          TodoData(
            title: "Vacuum living room"
          )
          TodoData(
            title: "Clean the garage",
            deadline: calendar.date( // Next Saturday at 10:00 AM
              bySettingHour: 10,
              minute: 0,
              second: 0,
              of: calendar.nextDate(
                after: .now,
                matching: DateComponents(weekday: 7),
                matchingPolicy: .nextTime)!)
          )
          TodoData(
            title: "Call mom",
            deadline: calendar.date( // Sunday at 3:00 PM
              bySettingHour: 15,
              minute: 0,
              second: 0,
              of: calendar.nextDate(
                after: .now,
                matching: DateComponents(weekday: 1),
                matchingPolicy: .nextTime)!)
          )
        }
      )
      TodoListData(
        name: "Errand Run",
        color: .green,
        todos: {
          TodoData(
            title: "Order printer ink"
          )
        }
      )
      TodoListData(
        name: "Finance",
        color: .blue,
        todos: {
          TodoData(
            title: "Reply to Sarah's email",
            notes: "About the project update"
          )
          TodoData(
            title: "Pay electricity bill",
            deadline: calendar.nextDate( // Next Monday
              after: .now,
              matching: DateComponents(weekday: 2),
              matchingPolicy: .nextTime)!
          )
          TodoData(
            title: "Finish quarterly report",
            notes: "Double-check revenue figures",
            deadline: calendar.date( // End of this month
              bySettingHour: 17,
              minute: 0,
              second: 0,
              of: calendar.date(
                byAdding: .month,
                value: 1,
                to: calendar.date(from: calendar.dateComponents([.year, .month], from: .now))!)!)!,
            frequencyUnit: .month,
            frequencyCount: 3
          )
        }
      )
      TodoListData(
        name: "Fitness",
        color: .red,
        todos: {
          TodoData(
            title: "Run 5k",
            notes: "Track time in Strava"
          )
        }
      )
      TodoListData(
        name: "Garden Chores",
        color: .brown,
        todos: {
          TodoData(
            title: "Water the plants",
            notes: "Especially the fern in the living room",
          )
        }
      )
      TodoListData(
        name: "Gift Shopping",
        color: .pink
      )
      TodoListData(
        name: "Health & Wellness",
        color: .red,
        todos: {
          TodoData(
            title: "Make dentist appointment",
            notes: "Prefer morning slot",
            completeDate: date.now
          )
          TodoData(
            title: "Read 'Atomic Habits'",
            deleteDate: date.now
          )
        }
      )
      TodoListData(
        name: "Home Repairs",
        color: .red
      )
      TodoListData(
        name: "Learning Skills",
        color: .green
      )
      TodoListData(
        name: .loremIpsum,
        color: .indigo,
        todos: {
          TodoData(
            title: .loremIpsum,
            notes: .loremIpsum
          )
          TodoData(
            title: .loremIpsum,
            notes: .loremIpsum,
            completeDate: date.now
          )
          TodoData(
            title: .loremIpsum,
            notes: .loremIpsum,
            deleteDate: date.now
          )
        }
      )
      TodoListData(
        name: "Meal Prep",
        color: .orange,
        todos: {
          TodoData(
            title: "Meal prep for the week",
            notes: "Try the new pasta salad recipe",
            deadline: calendar.date( // Sunday afternoon
              bySettingHour: 14,
              minute: 0,
              second: 0,
              of: calendar.nextDate(
                after: .now,
                matching: DateComponents(weekday: 1),
                matchingPolicy: .nextTime)!)!,
            frequencyUnit: .week,
            frequencyCount: 1
          )
          TodoData(
            title: "Buy groceries",
            notes: "Milk, eggs, bread, coffee",
            deadline: calendar.date( // Tomorrow at 5:00 PM
              bySettingHour: 17,
              minute: 0,
              second: 0,
              of: calendar.date(
                byAdding: .day,
                value: 1, to: .now)!)!,
            frequencyUnit: .week,
            frequencyCount: 1
          )
        }
      )
      TodoListData(
        name: "Morning Routine",
        color: .orange
      )
      TodoListData(
        name: "Moving Day Prep",
        color: .blue,
        todos: {
          TodoData(
            title: "Backup laptop",
            notes: "Use external SSD",
            deadline: calendar.date( // Friday at 8:00 PM
              bySettingHour: 20,
              minute: 0,
              second: 0,
              of: calendar.nextDate(
                after: .now,
                matching: DateComponents(weekday: 6),
                matchingPolicy: .nextTime)!)!
          )
        }
      )
      TodoListData(
        name: "Party Planning",
        color: .pink
      )
      TodoListData(
        name: "Pet Care",
        color: .purple,
        todos: {
          TodoData(
            title: "Walk the dog",
            deadline: calendar.date( // Today at 6:30 PM
              bySettingHour: 18,
              minute: 30,
              second: 0,
              of: .now)!
          )
        }
      )
      TodoListData(
        name: "Study Sessions",
        color: .blue
      )
      TodoListData(
        name: "Travel",
        color: .brown,
        todos: {
          TodoData(
            title: "Renew car registration",
            notes: "Bring insurance card",
            deadline: calendar.date( // Two weeks from today
              byAdding: .day,
              value: 14,
              to: .now)!,
            frequencyUnit: .year,
            frequencyCount: 1
          )
        }
      )
      TodoListData(
        name: "Weekend Projects",
        color: .purple,
        todos: {
          TodoData(
            title: "Plan weekend trip",
            notes: "Research hiking trails"
          )
        }
      )
    }
  }
}

#endif
