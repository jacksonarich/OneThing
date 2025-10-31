public extension RangeReplaceableCollection {
  func appending(_ element: Element) -> Self {
    var copy = self
    copy.append(element)
    return copy
  }
  
  func appending<S>(contentsOf sequence: S) -> Self where S: Sequence, S.Element == Element {
    var copy = self
    for element in sequence {
      copy.append(element)
    }
    return copy
  }
}
