//
//  EmptySearchPlaceholderViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@MainActor
struct EmptySearchPlaceholderViewSnapshotTests {

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func emptySearchPlaceholder_whenSearchQueryIsEmpty_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(searchText: "", size: size, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(of: sut, as: .image, named: "\(schemeName)_\(sizeName)")
    }

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func emptySearchPlaceholder_whenSearchQueryIsNotEmpty_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(searchText: "Muse", size: size, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(of: sut, as: .image, named: "\(schemeName)_\(sizeName)")
    }

    @Test(arguments: ["", "Muse"], [ColorScheme.dark, ColorScheme.light])
    func emptySearchPlaceholder_whenLayoutDirectionIsRightToLeft_rendersCorrectly(query: String, scheme: ColorScheme) {
        let sut = createSut(
            searchText: query,
            size: .medium,
            scheme: scheme,
            layoutDirection: .rightToLeft
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let queryName = query.isEmpty ? "empty" : "non-empty"

        assertSnapshot(of: sut, as: .image, named: "rtl_\(schemeName)_\(queryName)")
    }
}

extension EmptySearchPlaceholderViewSnapshotTests {
    fileprivate func createSut(
        searchText: String,
        size: DynamicTypeSize,
        scheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight
    ) -> some View {
        let background = scheme == .dark ? Color.black : Color.white
        return EmptySearchPlaceholderView(searchText: searchText)
            .environment(\.dynamicTypeSize, size)
            .environment(\.colorScheme, scheme)
            .environment(\.layoutDirection, layoutDirection)
            .background(background)
            .frame(width: 390)
    }
}
