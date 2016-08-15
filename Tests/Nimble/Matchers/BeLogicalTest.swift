import XCTest
import Nimble
import Foundation

enum ConvertsToBool : ExpressibleByBooleanLiteral, CustomStringConvertible {
    case trueLike, falseLike

    typealias BooleanLiteralType = Bool

    init(booleanLiteral value: Bool) {
        switch value {
        case true: self = .trueLike
        case false: self = .falseLike
        }
    }

    var boolValue : Bool {
        switch self {
        case .trueLike: return true
        case .falseLike: return false
        }
    }

    var description : String {
        switch self {
        case .trueLike: return "TrueLike"
        case .falseLike: return "FalseLike"
        }
    }
}

final class BeTruthyTest : XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeTruthyTest) -> () throws -> Void)] {
        return [
            ("testShouldMatchNonNilTypes", testShouldMatchNonNilTypes),
            ("testShouldMatchTrue", testShouldMatchTrue),
            ("testShouldNotMatchNilTypes", testShouldNotMatchNilTypes),
            ("testShouldNotMatchFalse", testShouldNotMatchFalse),
            ("testShouldNotMatchNilBools", testShouldNotMatchNilBools),
            ("testShouldMatchBoolConvertibleTypesThatConvertToTrue", testShouldMatchBoolConvertibleTypesThatConvertToTrue),
            ("testShouldNotMatchBoolConvertibleTypesThatConvertToFalse", testShouldNotMatchBoolConvertibleTypesThatConvertToFalse),
        ]
    }

    func testShouldMatchNonNilTypes() {
        expect(true as Bool?).to(beTruthy())
        #if _runtime(_ObjC)
            expect(1 as Int?).to(beTruthy())
        #else
            expect(1 as NSNumber?).to(beTruthy())
        #endif
    }

    func testShouldMatchTrue() {
        expect(true).to(beTruthy())

        failsWithErrorMessage("expected to not be truthy, got <true>") {
            expect(true).toNot(beTruthy())
        }
    }

    func testShouldNotMatchNilTypes() {
        expect(false as Bool?).toNot(beTruthy())
        expect(nil as Bool?).toNot(beTruthy())
        #if _runtime(_ObjC)
            expect(nil as Int?).toNot(beTruthy())
        #else
            expect(nil as NSNumber?).toNot(beTruthy())
        #endif
    }

    func testShouldNotMatchFalse() {
        expect(false).toNot(beTruthy())

        failsWithErrorMessage("expected to be truthy, got <false>") {
            expect(false).to(beTruthy())
        }
    }

    func testShouldNotMatchNilBools() {
        expect(nil as Bool?).toNot(beTruthy())

        failsWithErrorMessage("expected to be truthy, got <nil>") {
            expect(nil as Bool?).to(beTruthy())
        }
    }

    func testShouldMatchBoolConvertibleTypesThatConvertToTrue() {
        expect(ConvertsToBool.trueLike).to(beTruthy())

        failsWithErrorMessage("expected to not be truthy, got <TrueLike>") {
            expect(ConvertsToBool.trueLike).toNot(beTruthy())
        }
    }

    func testShouldNotMatchBoolConvertibleTypesThatConvertToFalse() {
        expect(ConvertsToBool.falseLike).toNot(beTruthy())

        failsWithErrorMessage("expected to be truthy, got <FalseLike>") {
            expect(ConvertsToBool.falseLike).to(beTruthy())
        }
    }
}

final class BeTrueTest : XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeTrueTest) -> () throws -> Void)] {
        return [
            ("testShouldMatchTrue", testShouldMatchTrue),
            ("testShouldNotMatchFalse", testShouldNotMatchFalse),
            ("testShouldNotMatchNilBools", testShouldNotMatchNilBools),
        ]
    }

    func testShouldMatchTrue() {
        expect(true).to(beTrue())

        failsWithErrorMessage("expected to not be true, got <true>") {
            expect(true).toNot(beTrue())
        }
    }

    func testShouldNotMatchFalse() {
        expect(false).toNot(beTrue())

        failsWithErrorMessage("expected to be true, got <false>") {
            expect(false).to(beTrue())
        }
    }

    func testShouldNotMatchNilBools() {
        failsWithErrorMessageForNil("expected to not be true, got <nil>") {
            expect(nil as Bool?).toNot(beTrue())
        }

        failsWithErrorMessageForNil("expected to be true, got <nil>") {
            expect(nil as Bool?).to(beTrue())
        }
    }
}

final class BeFalsyTest : XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeFalsyTest) -> () throws -> Void)] {
        return [
            ("testShouldMatchNilTypes", testShouldMatchNilTypes),
            ("testShouldNotMatchTrue", testShouldNotMatchTrue),
            ("testShouldNotMatchNonNilTypes", testShouldNotMatchNonNilTypes),
            ("testShouldMatchFalse", testShouldMatchFalse),
            ("testShouldMatchNilBools", testShouldMatchNilBools),
        ]
    }

    func testShouldMatchNilTypes() {
        expect(false as Bool?).to(beFalsy())
        expect(nil as Bool?).to(beFalsy())
        #if _runtime(_ObjC)
            expect(nil as Int?).to(beFalsy())
        #else
            expect(nil as NSNumber?).to(beFalsy())
        #endif
    }

    func testShouldNotMatchTrue() {
        expect(true).toNot(beFalsy())

        failsWithErrorMessage("expected to be falsy, got <true>") {
            expect(true).to(beFalsy())
        }
    }

    func testShouldNotMatchNonNilTypes() {
        expect(true as Bool?).toNot(beFalsy())
        #if _runtime(_ObjC)
            expect(1 as Int?).toNot(beFalsy())
        #else
            expect(1 as NSNumber?).toNot(beFalsy())
        #endif
    }

    func testShouldMatchFalse() {
        expect(false).to(beFalsy())

        failsWithErrorMessage("expected to not be falsy, got <false>") {
            expect(false).toNot(beFalsy())
        }
    }

    func testShouldMatchNilBools() {
        expect(nil as Bool?).to(beFalsy())

        failsWithErrorMessage("expected to not be falsy, got <nil>") {
            expect(nil as Bool?).toNot(beFalsy())
        }
    }
}

final class BeFalseTest : XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeFalseTest) -> () throws -> Void)] {
        return [
            ("testShouldNotMatchTrue", testShouldNotMatchTrue),
            ("testShouldMatchFalse", testShouldMatchFalse),
            ("testShouldNotMatchNilBools", testShouldNotMatchNilBools),
        ]
    }

    func testShouldNotMatchTrue() {
        expect(true).toNot(beFalse())

        failsWithErrorMessage("expected to be false, got <true>") {
            expect(true).to(beFalse())
        }
    }

    func testShouldMatchFalse() {
        expect(false).to(beFalse())

        failsWithErrorMessage("expected to not be false, got <false>") {
            expect(false).toNot(beFalse())
        }
    }

    func testShouldNotMatchNilBools() {
        failsWithErrorMessageForNil("expected to be false, got <nil>") {
            expect(nil as Bool?).to(beFalse())
        }

        failsWithErrorMessageForNil("expected to not be false, got <nil>") {
            expect(nil as Bool?).toNot(beFalse())
        }
    }
}
