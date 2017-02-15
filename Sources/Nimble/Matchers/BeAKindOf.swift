import Foundation

private func matcherMessage<T>(forType expectedType: T.Type) -> String {
    return "be a kind of \(String(describing: expectedType))"
}
private func matcherMessage(forClass expectedClass: AnyClass) -> String {
    return "be a kind of \(String(describing: expectedClass))"
}

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
public func beAKindOf<T>(_ expectedType: T.Type) -> Predicate<Any> {
    return Predicate.define { actualExpression in
        let message: ExpectationMessage

        let instance = try actualExpression.evaluate()
        guard let validInstance = instance else {
            message = .ExpectedValueTo(matcherMessage(forType: expectedType), "<nil>")
            return (.Fail, message)
        }
        message = .ExpectedValueTo(
            "be a kind of \(String(describing: expectedType))",
            "<\(String(describing: type(of: validInstance))) instance>"
        )

        return (Satisfiability(bool: validInstance is T), message)
    }
}

#if _runtime(_ObjC)

/// A Nimble matcher that succeeds when the actual value is an instance of the given class.
/// @see beAnInstanceOf if you want to match against the exact class
public func beAKindOf(_ expectedClass: AnyClass) -> Predicate<NSObject> {
    return Predicate.define { actualExpression in
        let message: ExpectationMessage
        let status: Satisfiability

        let instance = try actualExpression.evaluate()
        if let validInstance = instance {
            status = Satisfiability(bool: instance != nil && instance!.isKind(of: expectedClass))
            message = .ExpectedValueTo(
                matcherMessage(forClass: expectedClass),
                "<\(String(describing: type(of: validInstance))) instance>"
            )
        } else {
            status = .Fail
            message = .ExpectedValueTo(
                matcherMessage(forClass: expectedClass),
                "<nil>"
            )
        }

        return (status, message)
    }
}

extension NMBObjCMatcher {
    public class func beAKindOfMatcher(_ expected: AnyClass) -> NMBMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            return try! beAKindOf(expected).matches(actualExpression, failureMessage: failureMessage)
        }
    }
}

#endif
