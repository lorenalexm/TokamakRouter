//
// Navigator.swift
//
//
// Created by Alex Loren on 11/29/22.
//

import TokamakShim
import JavaScriptKit

public final class Navigator: ObservableObject {
	// MARK: - Properties.
	@Published private(set) var historyStack: [String]
	@Published private(set) var forwardStack: [String] = []

	private let initialHash: String
	private let location: JSObject?
	private let window: JSObject?

	// MARK: - Computed properties.
	var currentHash: String {
		return historyStack.last ?? initialHash
	}

	// MARK: - Initializer.
	/// Sets the `initialHash` and `historyStack` values.
	/// Configures a closure to observe `.onhashchange` events.
	/// - Parameter initialHash: The initial location hash.
	/// - Parameter jsInteropSkipped: Should the interop configuration with `JavaScriptKit` be skipped?
	private init(initialHash: String = "", jsInteropSkipped: Bool = false) {
		self.initialHash = initialHash
		historyStack = [initialHash]

		if !jsInteropSkipped {
			guard let location = JSObject.global.location.object,
			let window = JSObject.global.window.object else {
				fatalError("🛑 TokamakRouter: Unable to obtain Location or Window reference from JavaScriptKit!")
			}
			self.location = location
			self.window = window

			configureJSWindowEvents()
		} else {
			location = nil
			window = nil
		}

		if !initialHash.isEmpty {
			setLocationHash(to: initialHash)
		}
	}

	/// Sets the `initialHash` value.
	/// - Parameter initialHash: The initial location hash.
	public convenience init(initialHash: String = "") {
		self.init(initialHash: initialHash, jsInteropSkipped: false)
	}

	/// Removes the `.onhashchange` observer closure.
	deinit {
		window?.onhashchange = .undefined
	}

	// MARK: - Functions.
	/// Navigates to a new location, does nothing if attempting to navigate to the same hash.
	/// - Parameter hash: Hash of the new location to navigate to.
	public func navigate(to hash: String) {
		guard hash != currentHash else {
			return
		}

		forwardStack.removeAll()
		setLocationHash(to: hash)
	}

	/// Attempts to navigate a given number of steps backwards in history.
	/// The steps are clamped to the `historyStack.count`.
	/// - Parameter steps: Number of steps back in history to go.
	public func navigateBackwards(by steps: Int = 1) {
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
	public func navigateForwards(by steps: Int = 1) {
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
	public func clearHistory() {
		forwardStack.removeAll()
		historyStack = [currentHash]
	}

	/// Sets the location hash to the given string.
	/// - Parameter hash: Value of the new hash.
	private func setLocationHash(to hash: String) {
		guard let location = self.location else {
			return
		}
		location["hash"] = .string(hash)
	}

	/// Configuration for `JavaScriptKit` interop with the window object.
	private func configureJSWindowEvents() {
		let onHashChanged = JSClosure { [unowned self] _ in
			guard let location = self.location,
			let newHash = location["hash"].string else {
				return .undefined
			}

			guard newHash != currentHash else {
				#if DEBUG
				print("⚠️ TokamakRouter: New hash equals the current hash, no action taken.")
				#endif
				return .undefined
			}

			self.historyStack.append(newHash)
			return .undefined
		}
		window?.onhashchange = .object(onHashChanged)
	}
}

extension Navigator: Equatable {
	public static func ==(lhs: Navigator, rhs: Navigator) -> Bool {
		return lhs === rhs
	}
}

// MARK: - Testing extensions.
extension Navigator {
	#if DEBUG
	// Initializes the `Navigator` forcing configuration of `JavaScriptKit` items to be skipped.
	internal convenience init() {
		self.init(initialHash: "", jsInteropSkipped: true)
	}

	/// This function should *only* be used within testing.
	/// Navigates to a new location, does nothing if attempting to navigate to the same hash.
	/// - Parameter hash: Hash of the new location to navigate to.
	/// - Parameter forceAddHistory: Should this function push to the `historyStack`.
	internal func navigate(to hash: String, forceAddHistory: Bool = false) {
		guard hash != currentHash else {
			return
		}

		forwardStack.removeAll()
		if forceAddHistory == true {
			historyStack.append(hash)
		}
		setLocationHash(to: hash)
	}
	#endif
}
