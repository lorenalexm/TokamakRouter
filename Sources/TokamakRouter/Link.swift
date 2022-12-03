//
// Router.swift
//
//
// Created by Alex Loren on 12/02/22.
//

import TokamakShim

public struct Link<Content: View>: View {
	// MARK: - Properties.
	@EnvironmentObject private var navigator: Navigator

	private let hash: String
	private let content: () -> Content

	// MARK: - View declaration.
	public var body: some View {
		Button(action: onPressed) {
			content()
		}
	}

	// MARK: - Initializer.
	/// Sets the property values.
	/// - Parameter hash: The hash that this view will navigate to.
	/// - Parameter content: The content that will be shwon for the button.
	public init(to hash: String, @ViewBuilder content: @escaping () -> Content) {
		self.hash = hash
		self.content = content
	}

	// MARK: - Functions.
	/// Responder for the `Link` button. Navigates to the given `self.hash`.
	private func onPressed() {
		navigator.navigate(to: hash)
	}
}
