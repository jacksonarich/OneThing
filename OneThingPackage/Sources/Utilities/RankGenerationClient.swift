import AppModels
import Dependencies
import DependenciesMacros

@DependencyClient
public struct RankGenerationClient: Sendable {
  public var distribute: @Sendable (Int) -> [Rank] = { _ in [] }
  public var midpoint: @Sendable (_ between: Rank?, _ and: Rank?) -> Rank? = { _, _ in nil }
}

extension RankGenerationClient: DependencyKey {
  public static let liveValue = RankGenerationClient(
    distribute: { count in Rank.distributed(count: count) },
    midpoint: { left, right in Rank.midpoint(between: left, and: right) }
  )
  
  public static let testValue = RankGenerationClient(
    distribute: { count in
      precondition(count <= Alphabet.maxDigit, "Max count for tests is \(Alphabet.maxDigit)")
      // Creates a sequence of ranks starting at 0
      return (0..<count)
        .map { [$0].toRankString() }
        .map { Rank($0)! }
    },
    midpoint: { left, right in
      let leftDigits = left?.rawValue.toDigits()
      let rightDigits = right?.rawValue.toDigits()
      if leftDigits == nil, rightDigits == nil {
        // No ranks in the system; use the beginning of the sequence
        return Rank("0")
      } else if var leftDigits, rightDigits == nil, let lastIndex = leftDigits.indices.last {
        // Placing at the end; just increment the last digit
        // For example left = "3", right = nil, result is "4"
        leftDigits[lastIndex] += 1
        assert(leftDigits[lastIndex] <= Alphabet.maxDigit, "Exceeded alphabet length")
        return Rank(leftDigits.toRankString())!
      } else if leftDigits == nil, var rightDigits, let lastIndex = rightDigits.indices.last {
        // Placing at the beginning; decrement the last digit
        // For example left = nil, right = "3", result is "2"
        rightDigits[lastIndex] -= 1
        assert(rightDigits[lastIndex] >= Alphabet.minDigit, "Exceeded alphabet lower bound")
        return Rank(rightDigits.toRankString())!
      } else if let leftDigits, let rightDigits {
        if leftDigits.adjacent(to: rightDigits) {
          return nil
        }
        // Splitting between two ranks; add a 5 to the left rank
        // For example left = "1", right = "4", result is "15"
        return Rank(leftDigits.appending(5).toRankString())!
      } else {
        fatalError(
          "midpoint unknown for left \(left.debugDescription), right \(right.debugDescription)"
        )
      }
    }
  )
}

extension DependencyValues {
  public var rankGeneration: RankGenerationClient {
    get { self[RankGenerationClient.self] }
    set { self[RankGenerationClient.self] = newValue }
  }
}
