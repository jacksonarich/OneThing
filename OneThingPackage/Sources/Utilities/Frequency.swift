import AppModels


extension Frequency {
  public init?(
    selection: FrequencySelection,
    custom: Frequency
  ) {
    switch selection {
    case .never:
      return nil
    case .daily:
      self.init(unit: .day)
    case .weekly:
      self.init(unit: .week)
    case .monthly:
      self.init(unit: .month)
    case .yearly:
      self.init(unit: .year)
    case .custom:
      self = custom
    }
  }
}
