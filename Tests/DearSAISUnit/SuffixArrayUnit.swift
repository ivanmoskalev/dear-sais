import Testing
@testable import DearSAIS

@Test(
    arguments: [
        ("banana", [5, 3, 1, 0, 4, 2]),
        ("The quick brown fox jumps over the lazy dog.", [9, 39, 15, 19, 34, 25, 3, 30, 43, 0, 36, 10, 7, 40, 33, 2, 28, 16, 42, 32, 1, 6, 20, 8, 35, 22, 14, 41, 26, 12, 17, 23, 4, 29, 11, 24, 31, 5, 21, 27, 13, 18, 38, 37]),
        ("missisipi", [8, 6, 4, 1, 0, 7, 5, 3, 2]),
        ("cafééclair", [1, 9, 0, 7, 2, 10, 8, 11, 6, 4, 5, 3]),
    ]
)
func knownSmallStrings(string: String, suffixes: [Int]) async throws {
    #expect(SuffixArray.from(string: string) == suffixes)
    #expect(SuffixArray.from(string: string) == naiveSuffixArray(for: string))
}

@Test
func emptyString() async throws {
    #expect(SuffixArray.from(string: "") == [])
}

@Test
func singleCharacter() async throws {
    #expect(SuffixArray.from(string: "a") == [0])
    #expect(SuffixArray.from(string: "6") == [0])
}

@Test
func repeatedCharacters() async throws {
    #expect(SuffixArray.from(string: "aaa") == [2, 1, 0])
    #expect(SuffixArray.from(string: "aaaaa") == [4, 3, 2, 1, 0])
    #expect(SuffixArray.from(string: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") == [45, 44, 43, 42, 41, 40, 39, 38, 37, 36, 35, 34, 33, 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
}

@Test
func twoDistinctCharacters() async throws {
    #expect(SuffixArray.from(string: "abab") == [2, 0, 3, 1])
    #expect(SuffixArray.from(string: "383838383838383838") == [16, 14, 12, 10, 8, 6, 4, 2, 0, 17, 15, 13, 11, 9, 7, 5, 3, 1])
}

@Test
func fuzz() async throws {
    let numberOfTests = 100

    for _ in 0 ..< numberOfTests {
        let length = Int.random(in: 0 ..< 1024 * 5)
        var bytes = [UInt8]()
        bytes.reserveCapacity(length)
        for _ in 0 ..< length {
            bytes.append(UInt8.random(in: 1 ..< 255))
        }

        let computedSA = SuffixArray.from(bytes)
        let expectedSA = naiveSuffixArray(for: bytes)
        
        #expect(computedSA == expectedSA, "Mismatch for random data: \(bytes)")
    }
}

private func naiveSuffixArray(for string: String) -> [Int] {
    naiveSuffixArray(for: Array(string.utf8))
}

private func lexLessThan(_ lhs: ArraySlice<UInt8>, _ rhs: ArraySlice<UInt8>) -> Bool {
    for (a, b) in zip(lhs, rhs) {
        if a < b { return true }
        if a > b { return false }
    }
    return lhs.count < rhs.count
}

private func naiveSuffixArray(for data: [UInt8]) -> [Int] {
    let suffixSlices = (0 ..< data.count).map { i -> (Int, ArraySlice<UInt8>) in
        (i, data[i...])
    }
    let sortedSuffixes = suffixSlices.sorted { lexLessThan($0.1, $1.1) }
    return sortedSuffixes.map { $0.0 }
}
