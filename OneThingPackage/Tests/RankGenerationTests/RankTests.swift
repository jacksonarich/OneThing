import Algorithms
import AppModels
import CustomDump
@testable import RankGeneration
import Testing

struct AlphabetTests {
  @Test(arguments: ["0", "A", "z", "a0", "Zz", "0Za9"])
  func roundTrip(rankString: String) {
    let digits = rankString.toDigits()
    let back = digits.toRankString()
    #expect(back == rankString)
  }
  
#if os(macOS)
  @Test func invalidRankCharacter() async {
    await #expect(processExitsWith: .failure) {
      _ = "*".toDigits()
    }
  }
#endif
}

struct MidpointTests {
  @Test func noNeighbors() {
    let m = Rank.midpoint(between: nil, and: nil)
    expectNoDifference(.defaultMidpoint, m)
  }
  
  @Test func afterLastRank() throws {
    let m = try #require(Rank.midpoint(between: "a2", and: nil))
    #expect("a2" < m)
  }
  
  @Test func beforeFirstRank() throws {
    let m = try #require(Rank.midpoint(between: nil, and: "Z3"))
    #expect(m < "Z3")
  }
  
  @Test func beforeMinimum() {
    let m = Rank.midpoint(between: nil, and: "0")
    expectNoDifference(nil, m)
  }
  
  @Test func afterMaximum() throws {
    let m = try #require(Rank.midpoint(between: "z", and: nil))
    #expect("z" < m)
  }
  
  @Test func gapInColumn() {
    let m = Rank.midpoint(between: "a1", and: "a3")
    expectNoDifference("a2", m)
  }
  
  @Test func addColumn() throws {
    // A new digit will be added so the midpoint is between the given ranks
    let m = try #require(Rank.midpoint(between: "a1", and: "a2"))
    expect(m, between: "a1", and: "a2")
  }
  
  @Test func prefixNonMinimum() throws {
    let m = try #require(Rank.midpoint(between: "a", and: "ab"))
    expect(m, between: "a", and: "ab")
  }
  
  @Test(arguments: ["0", "9", "A", "Z", "a", "z", "ab"])
  func adjacent(prefix: String) {
    for zeroCount in 1..<5 {
      let zeros = String(repeating: "0", count: zeroCount)
      let m = Rank.midpoint(between: "\(prefix)", and: "\(prefix)\(zeros)")
      expectNoDifference(nil, m)
    }
  }
  
  @Test func reversedOrder() {
    let m1 = Rank.midpoint(between: "a1", and: "c5")
    let m2 = Rank.midpoint(between: "c5", and: "a1")
    expectNoDifference(m1, m2)
  }
  
  @Test func matchingRanks() {
    let m = Rank.midpoint(between: "a1", and: "a1")
    expectNoDifference(nil, m)
  }
  
  @Test func longRanks() {
    let prefix = String(repeating: "x", count: 50)
    let m = Rank.midpoint(between: "\(prefix)0", and: "\(prefix)2")
    expectNoDifference("\(prefix)1", m)
  }
  
  @Test func avoidAdjacentTrap() throws {
    // A valid solution is "a10", but that would create adjacent ranks at "a1" and "a10"
    // Instead, a digit is added to "a10" so it's between the two end points
    let m = try #require(Rank.midpoint(between: "a1", and: "a11"))
    expect(m, between: "a1", and: "a11")
  }
  
  @Test func avoidMinimumTrap() throws {
    // Make sure it never returns the minimum rank. Otherwise you can never get to the left of it
    let m = try #require(Rank.midpoint(between: nil, and: "1"))
    expect(m, between: "0", and: "1")
  }
  
  @Test func multipleMinimumDigits() throws {
    // Additional 0 digits are added to keep the midpoint from exceeding the right rank
    let m = try #require(Rank.midpoint(between: "a1", and: "a101"))
    expect(m, between: "a1", and: "a101")
  }
  
  @Test func repeatedInsertion() throws {
    let left: Rank = "a"
    var right: Rank = "b"
    for _ in 0..<100 {
      let m = try #require(Rank.midpoint(between: left, and: right))
      expect(m, between: left, and: right)
      right = m
    }
  }
  
  @Test func deterministic() async throws {
    let m1 = Rank.midpoint(between: "a1", and: "a2")
    let m2 = Rank.midpoint(between: "a1", and: "a2")
    expectNoDifference(m1, m2)
  }
}

func expect(_ mid: Rank, between left: Rank, and right: Rank) {
  #expect(left < mid)
  #expect(mid < right)
}

struct DistributionTests {
  @Test func empty() async throws {
    #expect(Rank.distributed(count: 0).isEmpty)
  }
  
  @Test func one() async throws {
    expectNoDifference([.defaultMidpoint], Rank.distributed(count: 1))
  }
  
  @Test(
    arguments: Array(1...63)
      .appending(100)
      .appending(500)
  )
  func monotonicallyIncreasing(count: Int) async throws {
    let ranks = Rank.distributed(count: count)
    for pair in ranks.adjacentPairs() {
      #expect(pair.0 < pair.1)
    }
  }
  
  @Test(
    arguments: Array(1...63)
      .appending(100)
      .appending(500)
  )
  func retainPrependAndAppend(count: Int) async throws {
    let ranks = Rank.distributed(count: count)
    let first = try #require(ranks.first)
    let last = try #require(ranks.last)
    #expect(Rank.midpoint(between: nil, and: first) != nil)
    #expect(Rank.midpoint(between: last, and: nil) != nil)
  }
  
  @Test(
    arguments: Array(1...63)
      .appending(100)
      .appending(500)
  )
  func evenSpacing(count: Int) async throws {
    let minimumValue = Rank.minimum.value
    let rankValues = Rank
      .distributed(count: count)
      .map(\.value)
    let spacing = Int(rankValues[0] - minimumValue)
    for pair in rankValues.adjacentPairs() {
      let pairSpacing = Int(pair.1 - pair.0)
      #expect(abs(pairSpacing - spacing) <= 1)
    }
  }
  
  @Test(arguments: [10, 100, 300])
  func deterministic(count: Int) async throws {
    let a = Rank.distributed(count: count)
    let b = Rank.distributed(count: count)
    #expect(a == b)
  }
}

extension Rank {
  var value: UInt64 {
    var value: UInt64 = 0
    for digit in rawValue.toDigits() {
      value *= 62
      value += UInt64(digit)
    }
    return value
  }
}
