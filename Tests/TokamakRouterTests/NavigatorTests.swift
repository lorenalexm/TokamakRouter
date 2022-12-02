//
// NavigatorTests.swift
//
//
// Created by Alex Loren on 11/29/22.
//

import XCTest
@testable import TokamakRouter

final class NavigatorTests: XCTestCase {
	// MARK: - Properties.
	private var navigator: Navigator!

	// MARK: - Test configuration.
	override func setUp() {
		navigator = Navigator()
	}

	override func tearDown() {
		navigator = nil
	}

	// MARK: - Test functions.
	func testNavigatorIsEquatable() {
		let clone = navigator!

		navigator.navigate(to: "foo", forceAddHistory: true)
		XCTAssertEqual(navigator, clone)

		navigator.navigateBackwards()
		XCTAssertEqual(navigator, clone)

		clone.navigate(to: "bar", forceAddHistory: true)
		XCTAssertEqual(clone, navigator)
	}

	func testNavigatorInitialHash() {
		let navigatorChangedHash = Navigator(hash: "foo")
		XCTAssertNotEqual(navigator, navigatorChangedHash)
		XCTAssertEqual(navigatorChangedHash.currentHash, "foo")
		XCTAssertEqual(navigatorChangedHash.historyStack.count, 1)
	}

	func testNavigateTo() {
		navigator.navigate(to: "foo", forceAddHistory: true)
		XCTAssertEqual(navigator.historyStack.count, 2)
		XCTAssertEqual(navigator.currentHash, "foo")
	}

	func testNavigateBackwards() {
		navigator.navigate(to: "foo", forceAddHistory: true)
		navigator.navigate(to: "bar", forceAddHistory: true)
		navigator.navigate(to: "fiz", forceAddHistory: true)
		navigator.navigate(to: "buzz", forceAddHistory: true)
		XCTAssertEqual(navigator.historyStack.count, 5)

		navigator.navigateBackwards(by: 2)
		XCTAssertEqual(navigator.historyStack.count, 3)
		XCTAssertEqual(navigator.currentHash, "bar")
	}

	func testNavigateForwards() {
		navigator.navigate(to: "foo", forceAddHistory: true)
		navigator.navigate(to: "bar", forceAddHistory: true)
		navigator.navigate(to: "fiz", forceAddHistory: true)
		navigator.navigate(to: "buzz", forceAddHistory: true)
		XCTAssertEqual(navigator.historyStack.count, 5)

		navigator.navigateBackwards(by: 3)
		XCTAssertEqual(navigator.historyStack.count, 2)
		XCTAssertEqual(navigator.currentHash, "foo")

		navigator.navigateForwards()
		XCTAssertEqual(navigator.historyStack.count, 3)
		XCTAssertEqual(navigator.currentHash, "bar")
	}

	func testClearHistory() {
		navigator.navigate(to: "foo", forceAddHistory: true)
		navigator.navigate(to: "bar", forceAddHistory: true)
		navigator.navigate(to: "fiz", forceAddHistory: true)
		navigator.navigate(to: "buzz", forceAddHistory: true)
		XCTAssertEqual(navigator.historyStack.count, 5)

		navigator.clearHistory()
		XCTAssertEqual(navigator.historyStack.count, 1)
	}
}
