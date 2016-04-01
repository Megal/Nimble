import Foundation

public func allPass<T,U where U: Sequence, U.Iterator.Element == T>
    (passFunc: (T?) -> Bool) -> NonNilMatcherFunc<U> {
        return allPass("pass a condition", passFunc)
}

public func allPass<T,U where U: Sequence, U.Iterator.Element == T>
    (passName: String, _ passFunc: (T?) -> Bool) -> NonNilMatcherFunc<U> {
        return createAllPassMatcher() {
            expression, failureMessage in
            failureMessage.postfixMessage = passName
            return passFunc(try expression.evaluate())
        }
}

public func allPass<U,V where U: Sequence, V: Matcher, U.Iterator.Element == V.ValueType>
    (matcher: V) -> NonNilMatcherFunc<U> {
        return createAllPassMatcher() {
            try matcher.matches($0, failureMessage: $1)
        }
}

private func createAllPassMatcher<T,U where U: Sequence, U.Iterator.Element == T>
    (elementEvaluator:(Expression<T>, FailureMessage) throws -> Bool) -> NonNilMatcherFunc<U> {
        return NonNilMatcherFunc { actualExpression, failureMessage in
            failureMessage.actualValue = nil
            if let actualValue = try actualExpression.evaluate() {
                for currentElement in actualValue {
                    #if swift(>=3)
                        let exp = Expression(
                            expression: {currentElement}, location: actualExpression.location)
                    #else
                        // FIXME: following force cast is needed for Swift3 to Swift 2.2
                        let exp = Expression(
                            expression: {currentElement as! U.Iterator.Element}, location: actualExpression.location)
                    #endif
                    if try !elementEvaluator(exp, failureMessage) {
                        failureMessage.postfixMessage =
                            "all \(failureMessage.postfixMessage),"
                            + " but failed first at element <\(stringify(currentElement))>"
                            + " in <\(stringify(actualValue))>"
                        return false
                    }
                }
                failureMessage.postfixMessage = "all \(failureMessage.postfixMessage)"
            } else {
                failureMessage.postfixMessage = "all pass (use beNil() to match nils)"
                return false
            }
            
            return true
        }
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func allPassMatcher(matcher: NMBObjCMatcher) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()
            var nsObjects = [NSObject]()
            
            var collectionIsUsable = true
            if let value = actualValue as? NSFastEnumeration {
                let generator = NSFastEnumerationIterator(value)
                while let obj:AnyObject = generator.next() {
                    if let nsObject = obj as? NSObject {
                        nsObjects.append(nsObject)
                    } else {
                        collectionIsUsable = false
                        break
                    }
                }
            } else {
                collectionIsUsable = false
            }
            
            if !collectionIsUsable {
                failureMessage.postfixMessage =
                  "allPass only works with NSFastEnumeration (NSArray, NSSet, ...) of NSObjects"
                failureMessage.expected = ""
                failureMessage.to = ""
                return false
            }
            
            let expr = Expression(expression: ({ nsObjects }), location: location)
            let elementEvaluator: (Expression<NSObject>, FailureMessage) -> Bool = {
                expression, failureMessage in
                return matcher.matches(
                    {try! expression.evaluate()}, failureMessage: failureMessage, location: expr.location)
            }
            return try! createAllPassMatcher(elementEvaluator).matches(
                expr, failureMessage: failureMessage)
        }
    }
}
#endif
