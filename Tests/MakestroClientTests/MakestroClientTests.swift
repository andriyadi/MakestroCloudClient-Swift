import XCTest
@testable import MakestroClient

class MakestroClientTests: XCTestCase {
    func testConnect() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Change the key with your own. Register at http://cloud.makestro.com
        let userKey = "[YOUR_OWN_KEY]"
        
        let client = MakestroClient(project: "swiftytest1",
                                    userName: "andri",
                                    userKey: userKey,
                                    deviceId: "7869699011711380805688")
        
        XCTAssertFalse(userKey == "[YOUR_OWN_KEY]", "Should change user key")
        
        do {
            try client.connect()
            sleep(5)
            XCTAssert(client.isConnected, "Client is connected")
        }
        catch {
            XCTAssert(false)
        }
    }


    static var allTests : [(String, (MakestroClientTests) -> () throws -> Void)] {
        return [
            ("testConnect", testConnect),
        ]
    }
}
