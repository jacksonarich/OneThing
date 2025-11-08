import AppModels
import Sharing


extension SharedKey where Self == AppStorageKey<Set<ComputedList>>.Default {
  static var hiddenLists: Self {
    Self[.appStorage("hiddenLists"), default: []]
  }
}
