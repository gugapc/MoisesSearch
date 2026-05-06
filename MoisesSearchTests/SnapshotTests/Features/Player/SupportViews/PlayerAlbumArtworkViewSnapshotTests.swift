//
//  PlayerAlbumArtworkViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 06/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@MainActor
struct PlayerAlbumArtworkViewSnapshotTests {

    // The success branch of `AsyncImage` requires real network loading and the `.empty`
    // branch overlays an animated `ProgressView` — neither is deterministic for snapshots.
    // We exercise the stable `nil`-URL placeholder branch across schemes and `maxSide`
    // values to cover layout correctness, fallback UI, and overall rendering stability.

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerAlbumArtwork_whenArtworkURLIsNil_rendersPlaceholder(scheme: ColorScheme) {
        let sut = createSut(artworkURL: nil, maxSide: 280, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "placeholder_\(schemeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerAlbumArtwork_whenMaxSideIsCompact_rendersPlaceholder(scheme: ColorScheme) {
        let sut = createSut(artworkURL: nil, maxSide: 200, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "compact_\(schemeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerAlbumArtwork_whenMaxSideIsLarge_rendersPlaceholder(scheme: ColorScheme) {
        let sut = createSut(artworkURL: nil, maxSide: 420, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "large_\(schemeName)")
    }
}

extension PlayerAlbumArtworkViewSnapshotTests {
    fileprivate func createSut(
        artworkURL: URL?,
        maxSide: CGFloat,
        scheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight
    ) -> some View {
        let background = scheme == .dark ? Color.black : Color.white
        return PlayerAlbumArtworkView(artworkURL: artworkURL, maxSide: maxSide)
            .environment(\.colorScheme, scheme)
            .environment(\.layoutDirection, layoutDirection)
            .padding(20)
            .background(background)
    }
}
