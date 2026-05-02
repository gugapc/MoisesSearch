//
//  SearchBarFieldTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 30/04/26.
//

import Testing
import ViewInspector
import SwiftUI
@testable import MoisesSearch

struct SearchBarFieldTests {
    @MainActor
    @Test func clearButton_whenTapped_clearsText() throws {
        var text = "draft"

        let sut = SearchBarField(
            text: Binding(
                get: { text },
                set: { text = $0 }
            )
        )

        let button = try sut.inspect()
            .find(viewWithAccessibilityIdentifier: "clear_search_button")
            .button()

        try button.tap()

        #expect(text.isEmpty)
    }
}
