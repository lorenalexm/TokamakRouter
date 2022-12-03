//
// Route.swift
//
//
// Created by Alex Loren on 12/02/22.
//

import TokamakShim

public struct Route<Content: View>: View {
	// MARK: - Properties.
	@EnvironmentObject private var navigator: Navigator 

	private let content: () -> Content
	private let hash: String

	// MARK: - View declaration.
	public var body: some View {
		return Group {
			if hash == navigator.currentHash {
				content()
					.environmentObject(navigator)
			}
		}
	}

	// MARK: - Initializer.
	/// Sets the property values.
	/// - Parameter hash: The hash location for this `Route`.
	/// - Parameter content: The view that should be shown when navigating to this `Route`.
	public init(_ hash: String = "", @ViewBuilder content: @escaping () -> Content) {
		self.hash = hash
		self.content = content
	}
}
