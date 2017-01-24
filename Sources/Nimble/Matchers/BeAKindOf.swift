import Foundation

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
public func beAKindOf<T>(_ expectedType: T.Type) -> Predicate<Any> {
    return Predicate {actualExpression, failureMessage -> Bool in
        failureMessage.postfixMessage = "be a kind of \(String(describing: expectedType))"
        let instance = try actualExpression.evaluate()
        guard let validInstance = instance else {
            failureMessage.actualValue = "<nil>"
            return false
        }

        failureMessage.actualValue = "<\(String(describing: type(of: validInstance))) instance>"

        guard validInstance is T else {
            return false
        }

        return true
    }.requireNonNil
}

#if _runtime(_ObjC)

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAnInstanceOf if you want to match against the exact class
public func beAKindOf(_ expectedClass: AnyClass) -> Predicate<NSObject> {
    return Predicate { actualExpression, failureMessage -> Bool in
        let instance = try actualExpression.evaluate()
        if let validInstance = instance {
            failureMessage.actualValue = "<\(String(describing: type(of: validInstance))) instance>"
        } else {
            failureMessage.actualValue = "<nil>"
        }
        failureMessage.postfixMessage = "be a kind of \(String(describing: expectedClass))"
        return instance != nil && instance!.isKind(of: expectedClass)
    }.requireNonNil
}

extension NMBObjCMatcher {
    public class func beAKindOfMatcher(_ expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            return try! beAKindOf(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}

#endif
