import AppModels
import NonEmpty

extension Rank {
  /// Generates evenly spaced rank values
  ///
  /// This is used when rebalancing the existing collections to keep the rank strings from getting too long. It's also used when seeding
  /// the database with rank values when converting from the old `order` integer values.
  static func distributed(count: Int) -> [Self] {
    guard count > 0 else { return [] }
    if count == 1 {
      return [.defaultMidpoint]
    }
    
    // Find the minimal fixed length L such that radix^L ≥ count
    let radix = Alphabet.bytes.count
    var rankLength = 1
    var capacity = radix
    while capacity <= count {
      capacity *= radix
      rankLength += 1
    }
    
    let segments = count + 1
    var (step, remainder) = capacity.quotientAndRemainder(dividingBy: segments)
    
    var digits = Array(repeating: 0, count: rankLength)
    
    var result: [Self] = []
    result.reserveCapacity(count)
    
    for _ in 0..<count {
      var carry = step
      if remainder > 0 {
        carry += 1
        remainder -= 1
      }
      var i = rankLength - 1
      while carry > 0 && i >= 0 {
        let sum = digits[i] + carry
        digits[i] = sum % radix
        carry = sum / radix
        i -= 1
      }
      
      result.append(.init(digits))
    }
    
    return result
  }
  
  static func midpoint(
    between previous: Self?,
    and next: Self?
  ) -> Self? {
    switch (previous?.rawValue, next?.rawValue) {
    case (nil, nil):
      return .defaultMidpoint
      
    case (let l?, let r?):
      // Ensure a < b
      let (a, b) = (l < r) ? (l, r) : (r, l)
      return midpoint(a.toDigits(), b.toDigits())
      
    default:
      return midpoint(
        previous?.rawValue.toDigits() ?? [],
        next?.rawValue.toDigits() ?? []
      )
    }
  }
  
  private static func midpoint(_ a: [Int], _ b: [Int]) -> Self? {
    if a == b || a.adjacent(to: b) {
      return nil
    }
    
    /// The common digits that prefix both `a` and `b`
    var prefix: [Int] = []
    for i in 0 ..< Swift.max(a.count, b.count) {
      // Missing digits behave like MIN for left and MAX for right
      // This makes prepend/append natural
      let left = (i < a.count) ? a[i] : Alphabet.minDigit
      let right = (i < b.count) ? b[i] : Alphabet.maxDigit
      
      if right - left > 1 {
        // Found a gap at this column so choose a midpoint and stop
        let mid = left + (right - left) / 2
        prefix.append(mid)
        return .init(prefix)
      } else {
        // No gap between digits so use the least digit (always on the left)
        prefix.append(left)
      }
    }
    
    let remainder = b.dropFirst(a.count)
    // a.count == b.count
    if remainder.isEmpty {
      return .init(a.appending(Alphabet.midDigit))
    }
    // Count the number of columns where there's no room (digit is either 0 or 1)
    let zeroCount = remainder
      .prefix { $0 <= 1 }
      .count
    let nextDigit: Int = {
      if let next = remainder.dropFirst(zeroCount).first {
        return next / 2
      } else {
        return Alphabet.midDigit
      }
    }()
    var result = a
    result.append(contentsOf: Array(repeating: Alphabet.minDigit, count: zeroCount))
    result.append(nextDigit)
    return .init(result)
  }
  
  private init(_ digits: [Int]) {
    self.init(digits.toRankString())!
  }
  
  /// Used as a rough midpoint when there are no other ranks
  static var defaultMidpoint: Self { .init([Alphabet.midDigit]) }
  
  /// Left-most possible rank
  static var minimum: Self { .init([Alphabet.minDigit]) }
}

struct Alphabet {
  /// ASCII-ordered characters as UTF-8 values
  ///
  /// Any change to the alphabet must be reflected in the `Rank` validation code
  static let bytes: [UInt8] = Array(
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".utf8
  )
  /// The smallest digit in the rank alphabet ('0')
  static let minDigit = 0
  /// The largest digit in the rank alphabet ('z')
  static let maxDigit = bytes.count - 1
  /// The center of the alphabet
  static let midDigit = bytes.count / 2
  /// A sentinel in `digits` that indicates there is no digit at that position
  private static let invalidDigit: Int = 0xFF
  
  /// Stores digits at their UTF-8 value position
  ///
  /// Use a UTF-8 value as an index into this array. The digit stored there is an index into `bytes`.
  /// Example:
  /// The UTF-8 value of 'C' is 67. The value at `indexes[67]` is 12 so the digit for 'C' is 12. When converting back from digit
  /// to Character, you'd call `bytes[12]` which would produce 67 which would decode to 'C'.
  ///
  /// The array is populated mostly with `invalidDigit`, but we use a count of 256 so that all UTF-8 bytes will work.
  private static let digits: [Int] = {
    var lookup = [Int](repeating: invalidDigit, count: 256)
    for (offset, byte) in bytes.enumerated() {
      lookup[Int(byte)] = offset
    }
    return lookup
  }()
  
  @inline(__always)
  static func toDigits(_ s: String) -> [Int] {
    var result = [Int]()
    result.reserveCapacity(s.utf8.count)
    for byte in s.utf8 {
      let digit = digits[Int(byte)]
      precondition(digit != invalidDigit, "Rank `\(s)` contains an invalid character")
      result.append(Int(digit))
    }
    return result
  }
  
  @inline(__always)
  static func fromDigits(_ digits: [Int]) -> String {
    String(
      decoding: digits.map { bytes[$0] },
      as: Unicode.UTF8.self
    )
  }
}

extension String {
  func toDigits() -> [Int] {
    Alphabet.toDigits(self)
  }
}

extension [Int] {
  func toRankString() -> String {
    Alphabet.fromDigits(self)
  }
  
  /// Digits are adjacent when they have identical prefixes and `next` has a trailing '0'
  ///
  /// Example: a = "Z4", b = "Z40". There is no rank between these two so they are "adjacent"
  func adjacent(to next: Self) -> Bool {
    next.prefix(self.count) == self[...]
    && next.dropFirst(self.count).allSatisfy { $0 == Alphabet.minDigit }
  }
}
