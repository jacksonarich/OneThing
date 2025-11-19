import AppModels


extension FrequencySelection {
  public init(
    _ frequency: Frequency?
  ) {
    switch frequency {
    case nil:
      self = .never
    case .init(unit: .day):
      self = .daily
    case .init(unit: .week):
      self = .weekly
    case .init(unit: .month):
      self = .monthly
    case .init(unit: .year):
      self = .yearly
    default:
      self = .custom
    }
  }
}
