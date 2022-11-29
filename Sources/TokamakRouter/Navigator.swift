//
// Navigator.swift
//
//
// Created by Alex Loren on 11/29/22.
//

#if os(WASI)

import TokamakDOM
import JavaScriptKit

final class Navigator: ObservableObject {
	// MARK: - Properties.
	@Published private(set) var historyStack: [String]
	@Published private(set) var forwardStack: [String] = []

	private let initialHash: String
	private let location: JSObject
	private let window: JSObject
	private var onHashChanged: JSClosure!

	// MARK: - Computed properties.
	var currentHash: String {
		return historyStack.last ?? initialHash
	}

	// MARK: - Initializer.
	/// Sets the initial and current hash values.
	/// Configures a closure to observe `.onhashchange` events.
	/// - Parameter initialHash: The initial location hash.
	init(initialHash: String = "") {
		self.initialHash = initialHash
		historyStack = [initialHash]
		location = JSObject.global.location.object!
		window = JSObject.global.window.object!

		let onHashChanged = JSClosure { [unowned self] _ in
			let hash = self.location["hash"].string!

			guard hash != currentHash else {
				return .undefined
			}

			self.historyStack.append(hash)
			return .undefined
		}
		window.onhashchange = .object(onHashChanged)
		self.onHashChanged = onHashChanged
	}

	/// Removes the `.onhashchange` observer closure.
	deinit {
		window.onhashchange = .undefined
	}

	// MARK: - Functions.
	/// Navigates to a new location, does nothing if attempting to navigate to the same hash.
	/// - Parameter hash: Hash of the new location to navigate to.
	func navigate(to hash: String) {
		guard hash != currentHash else {
			return
		}

		forwardStack.removeAll()
		setLocationHash(to: hash)
	}

	/// Attempts to navigate a given number of steps backwards in history.
	/// The steps are clamped to the `historyStack.count`.
	/// - Parameter steps: Number of steps back in history to go.
	func navigateBackwards(by steps: Int) {
		guard historyStack.count > 1 else {
			return
		}

		let totalSteps = min(steps, historyStack.count)
		let startingAt = historyStack.count - totalSteps
		forwardStack.append(contentsOf: historyStack[startingAt...].reversed())
		historyStack.removeLast(totalSteps)
		setLocationHash(to: currentHash)
	}

	/// Attempts to navigate a given number of steps forwards in history.
	/// The steps are clamped to the `forwardStack.count`.
	/// - Parameter steps: 
	func navigateForwards(by steps: Int) {
		guard !forwardStack.isEmpty else {
			return
		}

		let totalSteps = min(steps, forwardStack.count)
		let startingAt = forwardStack.count - totalSteps
		historyStack.append(contentsOf: forwardStack[startingAt...])
		forwardStack.removeLast(totalSteps)
		setLocationHash(to: currentHash)
	}

	/// Clears the forwards history. Sets the backwards history to current hash.
	func clearHistory() {
		forwardStack.removeAll()
		historyStack = [currentHash]
	}

	/// Sets the location hash to the given string.
	/// - Parameter hash: Value of the new hash.
	private func setLocationHash(to hash: String) {
		location["hash"] = .string(hash)
	}
}

extension Navigator: Equatable {
	public static func ==(lhs: Navigator, rhs: Navigator) -> Bool {
		return lhs === rhs
	}
}

#endif
