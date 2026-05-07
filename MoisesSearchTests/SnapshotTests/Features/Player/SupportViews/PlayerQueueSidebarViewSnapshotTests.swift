//
//  PlayerQueueSidebarViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 06/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@Suite(.tags(.snapshot))
@MainActor
struct PlayerQueueSidebarViewSnapshotTests {

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func playerQueueSidebar_whenMultipleTracks_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(
            tracks: .snapshotQueue,
            currentIndex: 1,
            size: size,
            scheme: scheme
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 320, height: 520)),
            named: "queue_\(schemeName)_\(sizeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerQueueSidebar_whenFirstTrackIsCurrent_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(
            tracks: .snapshotQueue,
            currentIndex: 0,
            size: .medium,
            scheme: scheme
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 320, height: 520)),
            named: "first-current_\(schemeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerQueueSidebar_whenLastTrackIsCurrent_rendersCorrectly(scheme: ColorScheme) {
        let tracks: [SongListItem] = .snapshotQueue
        let sut = createSut(
            tracks: tracks,
            currentIndex: tracks.count - 1,
            size: .medium,
            scheme: scheme
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 320, height: 520)),
            named: "last-current_\(schemeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerQueueSidebar_whenQueueIsEmpty_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(tracks: [], currentIndex: 0, size: .medium, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 320, height: 520)),
            named: "empty_\(schemeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerQueueSidebar_whenLayoutDirectionIsRightToLeft_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(
            tracks: .snapshotQueue,
            currentIndex: 1,
            size: .medium,
            scheme: scheme,
            layoutDirection: .rightToLeft
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 320, height: 520)),
            named: "rtl_\(schemeName)"
        )
    }
}

extension PlayerQueueSidebarViewSnapshotTests {
    fileprivate func createSut(
        tracks: [SongListItem],
        currentIndex: Int,
        size: DynamicTypeSize,
        scheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight
    ) -> some View {
        PlayerQueueSidebarView(
            tracks: tracks,
            currentIndex: currentIndex,
            onSelectTrack: { _ in }
        )
        .snapshotEnvironment(
            dynamicTypeSize: size,
            colorScheme: scheme,
            layoutDirection: layoutDirection
        )
    }
}

private extension Array where Element == SongListItem {
    static let snapshotQueue: [SongListItem] = [
        SongListItem(
            id: "snap-q1",
            title: "Instant Crush",
            artist: "Daft Punk feat. Julian Casablancas",
            albumTitle: "Random Access Memories"
        ),
        SongListItem(
            id: "snap-q2",
            title: "Get Lucky",
            artist: "Daft Punk feat. Pharrell Williams",
            albumTitle: "Random Access Memories"
        ),
        SongListItem(
            id: "snap-q3",
            title: "Around the World",
            artist: "Daft Punk",
            albumTitle: "Homework"
        ),
        SongListItem(
            id: "snap-q4",
            title: "An Unreasonably Long Song Title Used To Exercise Line Limiting In The Queue Row",
            artist: "Collaboration Between Several Artists With An Equally Long Credit Line",
            albumTitle: "Long Titles"
        ),
    ]
}
