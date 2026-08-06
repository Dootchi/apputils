import XCTest

@testable import apputils

final class RunnerTests: XCTestCase {
  func testPluginTypeIsAvailable() {
    XCTAssertNotNil(ApputilsPlugin())
  }
}
