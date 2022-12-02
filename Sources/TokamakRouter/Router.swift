//
// Router.swift
//
//
// Created by Alex Loren on 12/02/22.
//

import TokamakShim

public struct Router<Content: View>: View {
	// MARK: - Properties.
	@StateObject private var navigator: Navigator
	
	private let content: Content

	// MARK: - View declaration.
	public var body: some View {
		content
			.environmentObject(navigator)
	}

	// MARK: - Initializer.
	/// Initializes a new `Navigator` and sets as a `StateObject`.
	/// - Parameter initialHash: The initial hash value, in most cases this will be an empty string: ""
	/// - Parameter content: A view typically containing a number of `Route` views.
	public init(initialHash: String = "", @ViewBuilder content: () -> Content) {
		_navigator = StateObject(wrappedValue: Navigator(initialHash: initialHash))
		self.content = content()
	}
}
