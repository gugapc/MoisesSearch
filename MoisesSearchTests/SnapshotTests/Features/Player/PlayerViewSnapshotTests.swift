//
//  PlayerViewSnapshotTests.swift
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
struct PlayerViewSnapshotTests {

    // MARK: - Default (paused, first track)

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerView_whenDefault_rendersCorrectly(scheme: ColorScheme) {
        let viewModel = makeViewModel(startAt: 0, isPlaying: false, progress: 0)
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "default_\(schemeName)"
        )
    }

    // MARK: - Playing at mid-progress

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerView_whenPlayingAtMidProgress_rendersCorrectly(scheme: ColorScheme) {
        let viewModel = makeViewModel(startAt: 1, isPlaying: true, progress: 0.5)
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "playing-mid_\(schemeName)"
        )
    }

    // MARK: - Last track (next disabled)

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerView_whenAtLastTrack_rendersCorrectly(scheme: ColorScheme) {
        let viewModel = makeViewModel(startAt: PlayerViewSnapshotTests.snapshotQueue.count - 1,
                                      isPlaying: false,
                                      progress: 0)
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "last-track_\(schemeName)"
        )
    }

    // MARK: - Regular width (sidebar visible)

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerView_whenRegularWidth_rendersSidebarLayout(scheme: ColorScheme) {
        let viewModel = makeViewModel(startAt: 1, isPlaying: false, progress: 0.25)
        let sut = createSut(
            viewModel: viewModel,
            scheme: scheme,
            horizontalSizeClass: .regular
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 1024, height: 768)),
            named: "regular-width_\(schemeName)"
        )
    }

    // MARK: - Preview unavailable (no preview URL → error label, play disabled)

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerView_whenPreviewUnavailable_rendersErrorAndDisablesPlay(scheme: ColorScheme) {
        let viewModel = makeViewModel(startAt: 0, isPlaying: false, progress: 0, loaded: false)
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "preview-unavailable_\(schemeName)"
        )
    }

    // MARK: - Repeat enabled (icon tinted with accent color)

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerView_whenRepeatEnabled_rendersHighlightedRepeat(scheme: ColorScheme) {
        let viewModel = makeViewModel(startAt: 0, isPlaying: false, progress: 0)
        viewModel.isRepeatEnabled = true
        let sut = createSut(viewModel: viewModel, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "repeat-enabled_\(schemeName)"
        )
    }
}

extension PlayerViewSnapshotTests {
    /// Builds a `PlayerViewModel` pre-loaded with the deterministic snapshot queue.
    /// `loaded: true` (default) pins a 210s duration and clears the auto-set `playbackError`
    /// so the chrome renders as if the preview is ready to play. Pass `loaded: false` to
    /// keep the synchronous "Preview unavailable" state set by `replaceCurrentTrack()` when
    /// `previewURL` is nil.
    fileprivate func makeViewModel(
        startAt index: Int,
        isPlaying: Bool,
        progress: Double,
        loaded: Bool = true
    ) -> PlayerViewModel {
        let queue = PlaybackQueue()
        queue.replace(with: PlayerViewSnapshotTests.snapshotQueue, startAt: index)
        let viewModel = PlayerViewModel(playbackQueue: queue)
        viewModel.isPlaying = isPlaying
        viewModel.progress = progress
        if loaded {
            viewModel.duration = 210
            viewModel.playbackError = nil
        }
        return viewModel
    }

    fileprivate func createSut(
        viewModel: PlayerViewModel,
        scheme: ColorScheme,
        horizontalSizeClass: UserInterfaceSizeClass = .compact
    ) -> some View {
        let background = scheme == .dark ? Color.black : Color.white
        return NavigationStack {
            PlayerView(viewModel: viewModel)
        }
        .environment(\.colorScheme, scheme)
        .environment(\.horizontalSizeClass, horizontalSizeClass)
        .background(background)
    }

    /// Deterministic three-track queue. `artworkURL: nil` keeps `AsyncImage` on its
    /// stable placeholder branch (no real network during snapshot capture).
    fileprivate static let snapshotQueue: [SongListItem] = [
        SongListItem(
            id: "snap-p1",
            title: "Instant Crush",
            artist: "Daft Punk feat. Julian Casablancas",
            albumTitle: "Random Access Memories"
        ),
        SongListItem(
            id: "snap-p2",
            title: "Get Lucky",
            artist: "Daft Punk feat. Pharrell Williams",
            albumTitle: "Random Access Memories"
        ),
        SongListItem(
            id: "snap-p3",
            title: "Around the World",
            artist: "Daft Punk",
            albumTitle: "Homework"
        ),
    ]
}
