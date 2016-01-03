import XCTest
import Nimble

class SatisfyOneOfTest: XCTestCase {
    func testSatisfyOneOf() {
        expect(2).to(satisfyOneOf(equal(2), equal(3)))
        expect(2).toNot(satisfyOneOf(equal(3), equal("turtles")))
        expect([1,2,3]).to(satisfyOneOf(equal([1,2,3]), allPass({$0 < 4}), haveCount(3)))
        expect("turtle").toNot(satisfyOneOf(contain("a"), endWith("magic")))
        expect(82.0).toNot(satisfyOneOf(beLessThan(10.5), beGreaterThan(100.75), beCloseTo(50.1)))
        
        failsWithErrorMessage(
            "expected to match one of: {equal <3>}, {equal <4>}, {equal <5>}, got 2") {
                expect(2).to(satisfyOneOf(equal(3), equal(4), equal(5)))
        }
        failsWithErrorMessage(
            "expected to match one of: {all be less than 4, but failed first at element <5> in <[5, 6, 7]>}, {equal <[1, 2, 3, 4]>}, got [5, 6, 7]") {
                expect([5,6,7]).to(satisfyOneOf(allPass("be less than 4", {$0 < 4}), equal([1,2,3,4])))
        }
        failsWithErrorMessage(
            "expected to match one of: {be true}, got false") {
                expect(false).to(satisfyOneOf(beTrue()))
        }
        failsWithErrorMessage(
            "expected to not match one of: {be less than <10.5000>}, {be greater than <100.7500>}, {be close to <50.1000> (within 0.0001)}, got 50.10001") {
                expect(50.10001).toNot(satisfyOneOf(beLessThan(10.5), beGreaterThan(100.75), beCloseTo(50.1)))
        }
    }
}
