import AppModels


extension ComputedList {
  public static let completed = ComputedList(rawValue: "Computed")
  public static let deleted = ComputedList(rawValue: "Deleted")
  public static let scheduled = ComputedList(rawValue: "Scheduled")
  public static let inProgress = ComputedList(rawValue: "In Progress")
  
  static let all: [Self] = [
    .completed,
    .deleted,
    .scheduled,
    .inProgress
  ]
}
