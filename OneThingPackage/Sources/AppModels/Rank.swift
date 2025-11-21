import Foundation
import NonEmpty
import StructuredQueries

/// A compact, ordered identifier used for ranking items.
///
/// Guarantees:
/// - The string is non-empty
/// - All characters are members of the rank alphabet (see `Alphabet.bytes`)
public struct Rank: Codable, Hashable, QueryBindable, RawRepresentable, Sendable {
  public fileprivate(set) var rawValue: String
  
  @_disfavoredOverload
  public init?<T>(_ value: T) where T: LosslessStringConvertible {
    let s = String(value)
    guard s.isValidRank() else { return nil }
    self.rawValue = s
  }
  
  @_disfavoredOverload
  public init?(_ string: NonEmptyString) {
    guard string.isValidRank() else { return nil }
    self.init(string.rawValue)
  }
  
  public init?(rawValue: String) {
    guard rawValue.isValidRank() else { return nil }
    self.rawValue = rawValue
  }
  
  fileprivate init(verified: String) {
    self.rawValue = verified
  }
}

// MARK: - Conformances
extension Rank: ExpressibleByUnicodeScalarLiteral {
  public typealias UnicodeScalarLiteralType = String.UnicodeScalarLiteralType
  
  public init(unicodeScalarLiteral value: String.UnicodeScalarLiteralType) {
    let s = String(value)
    if s.isValidRank() {
      self.init(verified: s)
    } else {
      assertionFailure("Rank created with invalid unicode scalar literal: \(s)")
      // Fallback to a safe default within the alphabet to avoid trapping in release
      self.init(verified: "0")
    }
  }
}

extension Rank: ExpressibleByExtendedGraphemeClusterLiteral {
  public typealias ExtendedGraphemeClusterLiteralType = String.ExtendedGraphemeClusterLiteralType
  
  public init(extendedGraphemeClusterLiteral value: String.ExtendedGraphemeClusterLiteralType) {
    let s = String(value)
    if s.isValidRank() {
      self.init(verified: s)
    } else {
      assertionFailure("Rank created with invalid extended grapheme cluster literal: \(s)")
      self.init(verified: "0")
    }
  }
}

extension Rank: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String
  
  public init(stringLiteral value: String) {
    if value.isValidRank() {
      self.init(verified: value)
    } else {
      assertionFailure("Rank created with invalid string literal: \(value)")
      self.init(verified: "0")
    }
  }
}

extension Rank: CustomStringConvertible {
  public var description: String { rawValue }
}

extension Rank: ExpressibleByStringInterpolation {}

extension Rank: Comparable {
  public static func < (lhs: Rank, rhs: Rank) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

extension Rank: Collection {
  public typealias Index = String.Index
  public typealias Element = Character
  
  public var startIndex: Index { rawValue.startIndex }
  public var endIndex: Index { rawValue.endIndex }
  
  public func index(after i: Index) -> Index {
    rawValue.index(after: i)
  }
  
  public subscript(position: Index) -> Element {
    rawValue[position]
  }
}


// MARK: - Validation

private extension String {
  func isValidRank() -> Bool {
    // Must be non-empty and contain only allowed alphabet bytes
    guard let nonEmpty = NonEmptyString(self)
    else { return false }
    return nonEmpty.isValidRank()
  }
}

private extension NonEmptyString {
  func isValidRank() -> Bool {
    let allowed = Self.allowedBytes
    for byte in rawValue.utf8 {
      guard allowed.contains(byte)
      else { return false }
    }
    return true
  }
  
  /// Digits 0-9, uppercase A-Z, lowercase a-z
  ///
  /// Any change to this alphabet must be reflected in the `Alphabet.bytes` array
  static let allowedBytes: Set<UInt8> = Set(
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".utf8
  )
}
