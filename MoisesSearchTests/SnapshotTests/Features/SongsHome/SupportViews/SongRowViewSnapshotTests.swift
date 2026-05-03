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

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(
            of: sut,
            as: .image,
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

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image,
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

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image,
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

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image,
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
        .frame(width: 390)
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
