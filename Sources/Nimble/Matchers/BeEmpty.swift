import Foundation

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: Sequence>() -> Predicate<S> {
    return Predicate { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualSeq = try actualExpression.evaluate()
        if actualSeq == nil {
            return true
        }
        var generator = actualSeq!.makeIterator()
        return generator.next() == nil
    }.requireNonNil
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<String> {
    return Predicate { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualString = try actualExpression.evaluate()
        return actualString == nil || NSString(string: actualString!).length  == 0
    }.requireNonNil
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For NSString instances, it is an empty string.
public func beEmpty() -> Predicate<NSString> {
    return Predicate { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actualString = try actualExpression.evaluate()
        return actualString == nil || actualString!.length == 0
    }.requireNonNil
}

// Without specific overrides, beEmpty() is ambiguous for NSDictionary, NSArray,
// etc, since they conform to Sequence as well as NMBCollection.

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NSDictionary> {
	return Predicate { actualExpression, failureMessage in
		failureMessage.postfixMessage = "be empty"
		let actualDictionary = try actualExpression.evaluate()
		return actualDictionary == nil || actualDictionary!.count == 0
	}.requireNonNil
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NSArray> {
	return Predicate { actualExpression, failureMessage in
		failureMessage.postfixMessage = "be empty"
		let actualArray = try actualExpression.evaluate()
		return actualArray == nil || actualArray!.count == 0
	}.requireNonNil
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NMBCollection> {
    return Predicate { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be empty"
        let actual = try actualExpression.evaluate()
        return actual == nil || actual!.count == 0
    }.requireNonNil
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func beEmptyMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()
            failureMessage.postfixMessage = "be empty"
            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection }), location: location)
                return try! beEmpty().matches(expr, failureMessage: failureMessage)
            } else if let value = actualValue as? NSString {
                let expr = Expression(expression: ({ value as String }), location: location)
                return try! beEmpty().matches(expr, failureMessage: failureMessage)
            } else if let actualValue = actualValue {
                failureMessage.postfixMessage = "be empty (only works for NSArrays, NSSets, NSIndexSets, NSDictionaries, NSHashTables, and NSStrings)"
                failureMessage.actualValue = "\(String(describing: type(of: actualValue))) type"
            }
            return false
        }
    }
}
#endif
