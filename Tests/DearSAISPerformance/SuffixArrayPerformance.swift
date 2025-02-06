import XCTest
import DearSAIS

final class PerformanceTests: XCTestCase {
    func testBasicPerformance() {
        let length = 1024 * 5
        var bytes = [UInt8]()
        bytes.reserveCapacity(length)
        for _ in 0 ..< length {
            bytes.append(UInt8.random(in: 1 ..< 255))
        }
        measure {
            let _ = SuffixArray.from(bytes)
        }
    }
}
