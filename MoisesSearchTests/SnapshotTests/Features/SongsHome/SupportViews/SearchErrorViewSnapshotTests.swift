//
//  SearchErrorViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@Suite(.tags(.snapshot))
@MainActor
struct SearchErrorViewSnapshotTests {

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func searchErrorView_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(
            message: "Something went wrong. Check your connection and try again.",
            size: size,
            scheme: scheme
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(of: sut, as: .image, named: "\(schemeName)_\(sizeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func searchErrorView_whenLayoutDirectionIsRightToLeft_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(
            message: "Something went wrong. Check your connection and try again.",
            size: .medium,
            scheme: scheme,
            layoutDirection: .rightToLeft
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "rtl_\(schemeName)")
    }
}

extension SearchErrorViewSnapshotTests {
    fileprivate func createSut(
        message: String,
        size: DynamicTypeSize,
        scheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight
    ) -> some View {
        SearchErrorView(message: message, onRetry: {})
            .snapshotEnvironment(
                dynamicTypeSize: size,
                colorScheme: scheme,
                layoutDirection: layoutDirection,
                width: 390
            )
    }
}
