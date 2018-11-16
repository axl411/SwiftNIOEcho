import XCTest

import SwiftNIOEchoTests

var tests = [XCTestCaseEntry]()
tests += SwiftNIOEchoTests.allTests()
XCTMain(tests)