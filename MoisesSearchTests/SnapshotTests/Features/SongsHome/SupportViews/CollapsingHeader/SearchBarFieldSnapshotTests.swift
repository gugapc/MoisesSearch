//
//  SearchBarFieldSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 30/04/26.
//

import Testing
import SwiftUI
import SnapshotTesting
@testable import MoisesSearch

@Suite(.tags(.snapshot))
@MainActor
struct SearchBarFieldSnapshotTests {

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func searchBarField_whenTextIsEmpty_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(text: "", size: size, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(of: sut, as: .image, named: "\(schemeName)_\(sizeName)")
    }

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func searchBarField_whenTextIsNotEmpty_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(text: "draft", size: size, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(of: sut, as: .image, named: "\(schemeName)_\(sizeName)")
    }

    @Test(arguments: ["", "draft"], [ColorScheme.dark, ColorScheme.light])
    func searchBarField_whenLayoutDirectionIsRightToLeft_rendersCorrectly(text: String, scheme: ColorScheme) {
        let sut = createSut(
            text: text,
            size: .medium,
            scheme: scheme,
            layoutDirection: .rightToLeft
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let textName = text.isEmpty ? "empty" : text

        assertSnapshot(of: sut, as: .image, named: "rtl_\(schemeName)_\(textName)")
    }
}

// MARK: - Auxiliary functions

extension SearchBarFieldSnapshotTests {
    private func createSut(
        text: String,
        size: DynamicTypeSize,
        scheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight
    ) -> some View {
        SearchBarField(text: .constant(text))
            .snapshotEnvironment(
                dynamicTypeSize: size,
                colorScheme: scheme,
                layoutDirection: layoutDirection,
                width: 300
            )
    }
}
