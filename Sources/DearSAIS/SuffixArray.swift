// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SuffixArray.swift
// Part of the dear suite <https://github.com/ivanmoskalev/dear>.
// This code is released into the public domain under The Unlicense.
// For details, see <https://unlicense.org/>.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

public enum SuffixArray {
    /// Calculates a suffix array for the given string in O(n).
    /// - Parameter string: String.
    /// - Returns: A suffix array of the `string`
    @inlinable
    public static func from(string: String) -> [Int] {
        from(Array(string.utf8))
    }
    
    /// Calculates a suffix array for the given binary data in O(n).
    /// - Parameter data: Binary data.
    /// - Returns: A suffix array of the `data`
    /// - Complexity: O(n)
    public static func from(_ data: [UInt8]) -> [Int] {
        let n = data.count
        var SA = [Int](repeating: -1, count: n)
        saisInternal(data: ArraySlice(data.lazy.map(Int.init)), SA: &SA, keyBound: 256)
        return SA
    }
}

private func saisInternal(data: ArraySlice<Int>, SA: inout [Int], keyBound: Int) {
    if data.count == 1 {
        SA[0] = 0
    }

    if data.count < 2 {
        return
    }

    let (slPartition, lmsCount) = buildSLPartition(input: data)
    var lmsIndices = findLMSSuffixes(slPartition: ArraySlice(slPartition), lmsCount: lmsCount)
    let buckets = makeBucketCount(input: data, keyBound: keyBound)

    if lmsIndices.count > 1 {
        inducedSort(
            input: data,
            slPartition: ArraySlice(slPartition),
            lmsIndices: ArraySlice(lmsIndices),
            buckets: ArraySlice(buckets),
            suffixArray: &SA
        )
        var (lmsStr, labelCount) = labelLMSSubstrings(
            input: data,
            slPartition: ArraySlice(slPartition),
            suffixArray: ArraySlice(SA),
            lmsIndices: &lmsIndices
        )
        if labelCount < lmsStr.count {
            for (i, lmsIndex) in lmsIndices.enumerated() {
                SA[lmsIndex] = Int(lmsStr[i])
            }
            var previous_type = SL.S
            var j = 0
            for i in 0 ..< slPartition.count {
                let current_type = slPartition[i]
                if current_type == .S, previous_type == .L {
                    lmsStr[j] = Int(SA[i])
                    lmsIndices[j] = i
                    j += 1
                }
                previous_type = current_type
            }

            saisInternal(data: ArraySlice(lmsStr), SA: &SA, keyBound: lmsCount)

            for i in 0 ..< lmsIndices.count {
                SA[i] = lmsIndices[SA[i]]
            }

            let length = lmsIndices.count
            lmsIndices[0 ..< length] = SA[0 ..< length]
        }
    }

    inducedSort(
        input: data,
        slPartition: ArraySlice(slPartition),
        lmsIndices: ArraySlice(lmsIndices),
        buckets: ArraySlice(buckets),
        suffixArray: &SA
    )
}

private enum SL {
    case S
    case L
}

private func buildSLPartition(input: ArraySlice<Int>) -> ([SL], Int) {
    let length = input.count
    var lmsCount = 0
    var slPartition = [SL](repeating: .S, count: length)

    var previouS = SL.L
    var previousKey: Int?

    for i in stride(from: length - 1, through: 0, by: -1) {
        let currentKey = input[i]

        if previousKey == nil || currentKey > previousKey! {
            // When currentKey > next key or we are at the last character.
            if previouS == SL.S {
                // When transitioning from S_TYPE to L_TYPE,
                // it indicates that the suffix starting at the next position was a LMS suffix.
                lmsCount += 1
            }
            previouS = SL.L
        } else if currentKey < previousKey! {
            previouS = SL.S
        }

        slPartition[i] = previouS
        previousKey = currentKey
    }

    return (slPartition, lmsCount)
}

private func labelLMSSubstrings(
    input: ArraySlice<Int>,
    slPartition: ArraySlice<SL>,
    suffixArray: ArraySlice<Int>,
    lmsIndices: inout [Int]
) -> ([Int], Int) {
    let length = input.count
    var lmsStr = [Int](repeating: 0, count: lmsIndices.count)
    var label = 0
    var previousLms = 0
    var j = 0

    // Process each index in the suffix array.
    for currentLms in suffixArray[0 ..< length] {
        if currentLms > 0, slPartition[currentLms] == .S, slPartition[currentLms - 1] == .L {
            if previousLms != 0 {
                var currentLMSType = SL.S
                var previousLMSType = SL.S
                var k = 0
                while true {
                    var currentLMSEnd = false
                    var previousLMSEnd = false
                    
                    if currentLms + k >= length || (currentLMSType == .L && slPartition[currentLms + k] == .S) {
                        currentLMSEnd = true
                    }
                    if previousLms + k >= length || (previousLMSType == .L && slPartition[previousLms + k] == .S) {
                        previousLMSEnd = true
                    }

                    if currentLMSEnd && previousLMSEnd {
                        break
                    }

                    if currentLMSEnd != previousLMSEnd || input[currentLms + k] != input[previousLms + k] {
                        label += 1
                        break
                    }
                    
                    currentLMSType = slPartition[currentLms + k]
                    previousLMSType = slPartition[previousLms + k]
                    k += 1
                }
            }

            lmsIndices[j] = currentLms
            lmsStr[j] = Int(label)
            j += 1
            
            previousLms = currentLms
        }
    }

    return (lmsStr, label + 1)
}

private func findLMSSuffixes(slPartition: ArraySlice<SL>, lmsCount: Int) -> [Int] {
    var previous = SL.S
    var lmsIndices = [Int]()
    lmsIndices.reserveCapacity(lmsCount)

    for i in 0 ..< slPartition.count {
        let currentType = slPartition[i]
        if currentType == SL.S, previous == SL.L {
            lmsIndices.append(i)
        }
        previous = currentType
    }

    return lmsIndices
}

private func makeBucketCount(input: ArraySlice<Int>, keyBound: Int) -> [Int] {
    var buckets = [Int](repeating: 0, count: keyBound)
    for c in input {
        buckets[c] = buckets[c] + 1
    }
    return buckets
}

private func partialSum(_ buckets: ArraySlice<Int>, into bucketBounds: inout [Int], offset: Int = 0) {
    var sum = 0
    for i in 0 ..< min(buckets.count, bucketBounds.count - offset) {
        sum += buckets[i]
        bucketBounds[i + offset] = sum
    }
}

private func inducedSort(
    input: ArraySlice<Int>,
    slPartition: ArraySlice<SL>,
    lmsIndices: ArraySlice<Int>,
    buckets: ArraySlice<Int>,
    suffixArray: inout [Int]
) {
    let length = input.count
    for i in 0 ..< length {
        suffixArray[i] = length
    }

    assert(!buckets.isEmpty, "buckets must not be empty")

    var bucketBounds = [Int](repeating: 0, count: buckets.count)

    partialSum(buckets, into: &bucketBounds)
    
    for lmsIndex in lmsIndices.reversed() {
        let key = Int(input[lmsIndex])
        bucketBounds[key] -= 1
        suffixArray[bucketBounds[key]] = lmsIndex
    }

    bucketBounds[0] = 0
    partialSum(buckets, into: &bucketBounds, offset: 1)

    if slPartition[length - 1] == .L {
        let key = Int(input[length - 1])
        suffixArray[bucketBounds[key]] = length - 1
        bucketBounds[key] += 1
    }

    for i in 0 ..< length {
        let currentSuffix = suffixArray[i]
        if currentSuffix != length, currentSuffix > 0 {
            let currentSuffix = currentSuffix - 1
            if slPartition[currentSuffix] == .L {
                let key = Int(input[currentSuffix])
                suffixArray[bucketBounds[key]] = currentSuffix
                bucketBounds[key] += 1
            }
        }
    }

    partialSum(buckets, into: &bucketBounds)

    for i in (0 ..< length).reversed() {
        let currentSuffix = suffixArray[i]
        if currentSuffix != length, currentSuffix > 0 {
            let precedingIndex = currentSuffix - 1
            if slPartition[precedingIndex] == .S {
                let key = Int(input[precedingIndex])
                bucketBounds[key] -= 1
                suffixArray[bucketBounds[key]] = precedingIndex
            }
        }
    }

    if slPartition[length - 1] == .S {
        let key = Int(input[length - 1])
        bucketBounds[key] -= 1
        suffixArray[bucketBounds[key]] = length - 1
    }
}
