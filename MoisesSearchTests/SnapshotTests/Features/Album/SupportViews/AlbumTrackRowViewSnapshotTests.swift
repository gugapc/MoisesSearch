//
//  AlbumTrackRowViewSnapshotTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@Suite(.tags(.snapshot))
@MainActor
struct AlbumTrackRowViewSnapshotTests {
    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func albumTrackRowView_compact_rendersCorrectly(scheme: ColorScheme) {
        let sut = AlbumTrackRowView(track: snapshotTrack, onTap: {})
            .padding(.horizontal, 16)
            .frame(width: 390, alignment: .leading)
            .snapshotEnvironment(colorScheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "compact_\(schemeName)")
    }

    private let snapshotTrack = SongListItem(
        id: "snap-album-row-1",
        title: "Get Lucky",
        artist: "Daft Punk feat. Pharrell Williams",
        albumTitle: "Random Access Memories",
        collectionId: 555
    )
}
