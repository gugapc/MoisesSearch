//
//  SongRowViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@MainActor
struct SongRowViewSnapshotTests {

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func songRowView_whenShowsMoreButton_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSongRowSut(
            item: .snapshotShort,
            showsMoreButton: true,
            size: size,
            scheme: scheme
        )

        let schemeName = scheme == .dark ? "dark" : "light"
        let sizeName = sizeName(for: size)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 88)),
            named: "more_\(schemeName)_\(sizeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songRowView_whenMoreButtonHidden_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSongRowSut(
            item: .snapshotShort,
            showsMoreButton: false,
            size: .medium,
            scheme: scheme
        )

        let schemeName = scheme == .dark ? "dark" : "light"

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 88)),
            named: "no-more_\(schemeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songRowView_whenLongText_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSongRowSut(
            item: .snapshotLongLines,
            showsMoreButton: true,
            size: .medium,
            scheme: scheme
        )

        let schemeName = scheme == .dark ? "dark" : "light"

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 88)),
            named: "long-text_\(schemeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songRowView_whenLayoutDirectionIsRightToLeft_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSongRowSut(
            item: .snapshotShort,
            showsMoreButton: true,
            size: .medium,
            scheme: scheme,
            layoutDirection: .rightToLeft
        )

        let schemeName = scheme == .dark ? "dark" : "light"

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 88)),
            named: "rtl_\(schemeName)"
        )
    }
}

extension SongRowViewSnapshotTests {
    fileprivate func createSongRowSut(
        item: SongListItem,
        showsMoreButton: Bool,
        size: DynamicTypeSize,
        scheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight
    ) -> some View {
        let background = scheme == .dark ? Color.black : Color.white
        return SongRowView(
            item: item,
            showsMoreButton: showsMoreButton,
            onTapRow: {},
            onMore: {}
        )
        .environment(\.dynamicTypeSize, size)
        .environment(\.colorScheme, scheme)
        .environment(\.layoutDirection, layoutDirection)
        .background(background)
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

private extension SongListItem {
    static let snapshotShort = SongListItem(id: "snap-1", title: "Purple Rain", artist: "Prince")

    static let snapshotLongLines = SongListItem(
        id: "snap-2",
        title: "An Unreasonably Long Song Title Used To Exercise Line Limiting In The Row",
        artist: "Collaboration Between Several Artists With An Equally Long Credit Line"
    )
}
