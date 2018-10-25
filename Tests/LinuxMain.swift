import XCTest

@testable import AppTests

XCTMain([
    testCase(AcronymTests.allTests),
    testCase(CategoryTests.allTests),
    testCase(UserTests.allTests),
])
