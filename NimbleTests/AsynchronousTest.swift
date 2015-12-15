import XCTest
import Nimble
import Swift

class AsyncTest: XCTestCase {
    let errorToThrow = NSError(domain: NSInternalInconsistencyException, code: 42, userInfo: nil)

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testAsyncTestingViaEventuallyPositiveMatches() {
        var value = 0
        deferToMainQueue { value = 1 }
        expect { value }.toEventually(equal(1))

        deferToMainQueue { value = 0 }
        expect { value }.toEventuallyNot(equal(1))
    }

    func testAsyncTestingViaEventuallyNegativeMatches() {
        let value = 0
        failsWithErrorMessage("expected to eventually not equal <0>, got <0>") {
            expect { value }.toEventuallyNot(equal(0))
        }
        failsWithErrorMessage("expected to eventually equal <1>, got <0>") {
            expect { value }.toEventually(equal(1))
        }
        failsWithErrorMessage("expected to eventually equal <1>, got an unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventually(equal(1))
        }
        failsWithErrorMessage("expected to eventually not equal <0>, got an unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventuallyNot(equal(0))
        }
    }

    func testAsyncTestingViaWaitUntilPositiveMatches() {
        waitUntil { done in
            done()
        }
        waitUntil { done in
            deferToMainQueue {
                done()
            }
        }
    }

    func testAsyncTestngViaWaitUntilTimesOutIfNotCalled() {
        failsWithErrorMessage("Waited more than 1.0 second") {
            waitUntil(timeout: 1) { done in return }
        }
    }

    func testAsyncTestingViaWaitUntilTimesOutWhenSleepingOnMainThreadAsync() {
        var waiting = true
        failsWithErrorMessage("Waited more than 0.01 seconds") {
            waitUntil(timeout: 0.01) { done in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    NSThread.sleepForTimeInterval(0.1)
                    done()
                    waiting = false
                }
            }
        }

        // "clear" runloop to ensure this test doesn't poison other tests
        repeat {
            NSRunLoop.mainRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(0.2))
        } while(waiting)
    }

    func testAsyncTestingViaWaitUntilNegativeMatches() {
        failsWithErrorMessage("expected to equal <2>, got <1>") {
            waitUntil { done in
                NSThread.sleepForTimeInterval(0.1)
                expect(1).to(equal(2))
                done()
            }
        }
    }

    func testWaitUntilDetectsStalledMainThreadActivity() {
        failsWithErrorMessage("Stall on main thread - too much enqueued on main run loop before waitUntil executes.") {
            print("start")
            waitUntil(timeout: 1) { done in
                print("waitUntil")
                dispatch_async(dispatch_get_main_queue()) {
                    print("dispatch")
                    NSThread.sleepForTimeInterval(5.0)
                    print("done")
                    done()
                }
            }
        }
    }

    func testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed() {
        let referenceLine = __LINE__ + 7
        var msg = "Unexpected exception raised: Nested async expectations are not allowed...\n\n"
        msg += "The call to\n\t"
        msg += "expect(...).toEventually(...) at \(__FILE__):\(referenceLine + 7)\n"
        msg += "triggered this exception because\n\t"
        msg += "waitUntil(...) at \(__FILE__):\(referenceLine + 1)\n"
        msg += "is currently managing the main run loop."
        failsWithErrorMessage(msg) {
            waitUntil(timeout: 2.0) { done in
                var protected: Int = 0
                dispatch_async(dispatch_get_main_queue()) {
                    protected = 1
                }

                expect(protected).toEventually(equal(1))
                done()
            }
        }
    }
}
