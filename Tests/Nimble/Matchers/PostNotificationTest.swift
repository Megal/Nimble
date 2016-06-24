import XCTest
import Nimble
import Foundation

final class PostNotificationTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (PostNotificationTest) -> () throws -> Void)] {
        return [
            ("testPassesWhenNoNotificationsArePosted", testPassesWhenNoNotificationsArePosted),
            ("testPassesWhenExpectedNotificationIsPosted", testPassesWhenExpectedNotificationIsPosted),
            ("testPassesWhenAllExpectedNotificationsArePosted", testPassesWhenAllExpectedNotificationsArePosted),
            ("testFailsWhenNoNotificationsArePosted", testFailsWhenNoNotificationsArePosted),
            ("testFailsWhenNotificationWithWrongNameIsPosted", testFailsWhenNotificationWithWrongNameIsPosted),
            ("testFailsWhenNotificationWithWrongObjectIsPosted", testFailsWhenNotificationWithWrongObjectIsPosted),
            ("testPassesWhenExpectedNotificationEventuallyIsPosted", testPassesWhenExpectedNotificationEventuallyIsPosted),
        ]
    }

    let notificationCenter = NotificationCenter()

    func testPassesWhenNoNotificationsArePosted() {
        expect {
            // no notifications here!
            return nil
        }.to(postNotifications(beEmpty(), fromNotificationCenter: notificationCenter))
    }

    func testPassesWhenExpectedNotificationIsPosted() {
        let testNotification = Notification(name: Notification.Name("Foo"), object: nil)
        expect {
            self.notificationCenter.post(testNotification)
        }.to(postNotifications(equal([testNotification.name]), fromNotificationCenter: notificationCenter))
    }

    func testPassesWhenAllExpectedNotificationsArePosted() {
        let foo = NSNumber(value: 1)
        let bar = NSNumber(value: 2)
        let n1 = Notification(name: Notification.Name("Foo"), object: foo)
        let n2 = Notification(name: Notification.Name("Bar"), object: bar)
        expect {
            self.notificationCenter.post(n1)
            self.notificationCenter.post(n2)
            return nil
        }.to(postNotifications(equal([n1.name, n2.name]), fromNotificationCenter: notificationCenter))
    }

    func testFailsWhenNoNotificationsArePosted() {
        let testNotification = Notification(name: Notification.Name("Foo"), object: nil)
        failsWithErrorMessage("expected to equal <[Name(_rawValue: \(testNotification.name.rawValue))]>, got no notifications") {
            expect {
                // no notifications here!
                return nil
            }.to(postNotifications(equal([testNotification.name]), fromNotificationCenter: self.notificationCenter))
        }
    }

    func testFailsWhenNotificationWithWrongNameIsPosted() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        let n2 = Notification(name: Notification.Name(n1.name.rawValue + "a"), object: nil)
        failsWithErrorMessage("expected to equal <[Name(_rawValue: \(n1.name.rawValue))]>, got <[Name(_rawValue: \(n2.name.rawValue))]>") {
            expect {
                self.notificationCenter.post(n2)
                return nil
            }.to(postNotifications(equal([n1.name]), fromNotificationCenter: self.notificationCenter))
        }
    }

    func testFailsWhenNotificationWithWrongObjectIsPosted() {
        let n1 = Notification(name: Notification.Name("Foo"), object: nil)
        let n2 = Notification(name: n1.name, object: NSObject())
        failsWithErrorMessage("expected to equal <[Name(_rawValue: \(n1.name.rawValue))]>, got <[Name(_rawValue: \(n2.name.rawValue))]>") {
            expect {
                self.notificationCenter.post(n2)
                return nil
            }.to(postNotifications(equal([n1.name]), fromNotificationCenter: self.notificationCenter))
        }
    }

    func testPassesWhenExpectedNotificationEventuallyIsPosted() {
        #if _runtime(_ObjC)
            let testNotification = Notification(name: Notification.Name("Foo"), object: nil)
            expect {
                deferToMainQueue {
                    self.notificationCenter.post(testNotification)
                }
                return nil
            }.toEventually(postNotifications(equal([testNotification.name]), fromNotificationCenter: notificationCenter))
        #else
            print("\(#function) is missing because toEventually is not implement on this platform")
        #endif
    }
}
