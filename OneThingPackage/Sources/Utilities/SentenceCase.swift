extension String {
  public var sentenceCased: String {
    guard let first else { return self }
    return String(first).uppercased() + dropFirst()
  }
}
