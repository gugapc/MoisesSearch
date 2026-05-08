//
//  AlbumViewSnapshotTests.swift
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
struct AlbumViewSnapshotTests {
    // MARK: - Loaded compact (iPhone)

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func albumView_whenLoadedCompact_rendersCorrectly(scheme: ColorScheme) {
        let viewModel = makeViewModel(state: .loaded(Self.loadedDetail))
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "loaded-compact_\(schemeName)"
        )
    }

    // MARK: - Loaded regular (iPad)

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func albumView_whenLoadedRegular_rendersCorrectly(scheme: ColorScheme) {
        let viewModel = makeViewModel(state: .loaded(Self.loadedDetail))
        let sut = createSut(viewModel: viewModel, scheme: scheme, horizontalSizeClass: .regular)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 1024, height: 768)),
            named: "loaded-regular_\(schemeName)"
        )
    }

    // MARK: - Loading

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func albumView_whenLoading_rendersProgressIndicator(scheme: ColorScheme) {
        let viewModel = makeViewModel(state: .loading)
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "loading_\(schemeName)"
        )
    }

    // MARK: - Failed

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func albumView_whenFailed_rendersErrorWithRetry(scheme: ColorScheme) {
        let viewModel = makeViewModel(state: .failed("The internet connection appears to be offline."))
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "failed_\(schemeName)"
        )
    }
}

extension AlbumViewSnapshotTests {
    /// Constructs a VM with state pre-set. `AlbumView.task` only fires `load()` when state
    /// is `.idle`, so a non-idle state here keeps the snapshot deterministic — no network call.
    fileprivate func makeViewModel(state: AlbumViewModel.LoadState) -> AlbumViewModel {
        let vm = AlbumViewModel(
            collectionId: 555,
            repository: MockAlbumRepository(),
            onPlayTracks: { _, _ in }
        )
        vm.state = state
        return vm
    }

    fileprivate func createSut(
        viewModel: AlbumViewModel,
        scheme: ColorScheme,
        horizontalSizeClass: UserInterfaceSizeClass = .compact
    ) -> some View {
        let background = scheme == .dark ? Color.black : Color.white
        return NavigationStack {
            AlbumView(viewModel: viewModel)
        }
        .environment(\.colorScheme, scheme)
        .environment(\.horizontalSizeClass, horizontalSizeClass)
        .background(background)
    }

    /// Three-track deterministic album. `nil` artwork keeps `AsyncImage` on its placeholder branch.
    fileprivate static let loadedDetail = AlbumDetail(
        collectionId: 555,
        title: "Random Access Memories",
        artist: "Daft Punk",
        artworkURL: nil,
        trackCount: 3,
        tracks: [
            SongListItem(
                id: "snap-a1",
                title: "Give Life Back to Music",
                artist: "Daft Punk",
                albumTitle: "Random Access Memories",
                collectionId: 555
            ),
            SongListItem(
                id: "snap-a2",
                title: "Get Lucky",
                artist: "Daft Punk feat. Pharrell Williams",
                albumTitle: "Random Access Memories",
                collectionId: 555
            ),
            SongListItem(
                id: "snap-a3",
                title: "Lose Yourself to Dance",
                artist: "Daft Punk",
                albumTitle: "Random Access Memories",
                collectionId: 555
            ),
        ]
    )
}
