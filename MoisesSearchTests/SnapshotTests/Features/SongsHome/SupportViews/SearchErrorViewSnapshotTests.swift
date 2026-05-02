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

@MainActor
struct SearchErrorViewSnapshotTests {

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func searchErrorView_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(
            message: "Something went wrong. Check your connection and try again.",
            size: size,
            scheme: scheme
        )

        let schemeName = scheme == .dark ? "dark" : "light"
        let sizeName = sizeName(for: size)

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

        let schemeName = scheme == .dark ? "dark" : "light"

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
        let background = scheme == .dark ? Color.black : Color.white
        return SearchErrorView(message: message, onRetry: {})
            .environment(\.dynamicTypeSize, size)
            .environment(\.colorScheme, scheme)
            .environment(\.layoutDirection, layoutDirection)
            .background(background)
            .frame(width: 390)
    }

    fileprivate func sizeName(for size: DynamicTypeSize) -> String {
        switch size {
        case .xSmall:
            "xSmall"
        case .medium:
            "medium"
        case .xxxLarge:
            "xxxLarge"
        default:
            "unsupported"
        }
    }
}
