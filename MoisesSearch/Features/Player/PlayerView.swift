//
//  PlayerView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI

struct PlayerView: View {
    @State private var viewModel: PlayerViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let onShowAlbum: ((Int) -> Void)?

    init(playbackQueue: PlaybackQueue, onShowAlbum: ((Int) -> Void)? = nil) {
        _viewModel = State(initialValue: PlayerViewModel(playbackQueue: playbackQueue))
        self.onShowAlbum = onShowAlbum
    }

    /// Test seam: lets snapshot/unit tests inject a pre-configured view model
    /// (e.g. fixed `progress` / `isPlaying`, slow ticker interval).
    init(viewModel: PlayerViewModel, onShowAlbum: ((Int) -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.onShowAlbum = onShowAlbum
    }

    private var showPlayQueueSidebar: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        layout
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.navigationAlbumTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    let collectionId = viewModel.currentTrack?.collectionId
                    Menu {
                        Button(String(localized: "View album")) {
                            if let collectionId {
                                onShowAlbum?(collectionId)
                            }
                        }
                        .accessibilityIdentifier("player_view_album")
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body.weight(.medium))
                    }
                    .disabled(collectionId == nil)
                    .accessibilityLabel(String(localized: "More"))
                    .accessibilityIdentifier("player_more")
                }
            }
    }

    @ViewBuilder
    private var layout: some View {
        if showPlayQueueSidebar {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            artworkSection(maxWidth: nil)
            chrome
        }
    }

    private var iPadLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                artworkSection(maxWidth: 520)
                chrome
            }
            .frame(maxWidth: .infinity)

            Divider()

            PlayerQueueSidebarView(
                tracks: viewModel.playbackQueue.tracks,
                currentIndex: viewModel.playbackQueue.currentIndex,
                onSelectTrack: { viewModel.jumpToTrack(at: $0) }
            )
        }
    }

    private func artworkSection(maxWidth: CGFloat?) -> some View {
        GeometryReader { geo in
            let side = Self.artworkSideLength(
                container: geo.size,
                maxCap: maxWidth,
                isRegularWidth: showPlayQueueSidebar
            )
            VStack {
                Spacer(minLength: 12)
                PlayerAlbumArtworkView(
                    artworkURL: viewModel.currentTrack?.artworkURL,
                    maxSide: side
                )
                .frame(maxWidth: .infinity)
                Spacer(minLength: 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var chrome: some View {
        @Bindable var viewModel = viewModel
        return PlayerBottomChromeView(
            trackTitle: viewModel.currentTrack?.title ?? "—",
            artistName: viewModel.currentTrack?.artist ?? "",
            progress: $viewModel.progress,
            isPlaying: $viewModel.isPlaying,
            isRepeatEnabled: $viewModel.isRepeatEnabled,
            durationSeconds: viewModel.duration ?? 0,
            onPrevious: { viewModel.previous() },
            onNext: { viewModel.next() },
            onScrubbingChanged: { editing in
                editing ? viewModel.beginScrubbing() : viewModel.endScrubbing()
            },
            hasPrevious: viewModel.canRewind,
            hasNext: viewModel.canAdvance,
            playbackErrorMessage: viewModel.playbackError
        )
    }

    private static func artworkSideLength(container: CGSize, maxCap: CGFloat?, isRegularWidth: Bool) -> CGFloat {
        let widthBudget = maxCap.map { min(container.width, $0) } ?? container.width
        let heightBudget = container.height
        let ratio: CGFloat = isRegularWidth ? 0.52 : 0.72
        let fromHeight = heightBudget * ratio
        let fromWidth = widthBudget - 40
        let raw = min(fromHeight, fromWidth, isRegularWidth ? 420 : 380)
        return max(200, raw)
    }
}

#Preview("Player") {
    let queue = PlaybackQueue()
    queue.replace(
        with: [
            SongListItem(
                id: "1",
                title: "Instant Crush",
                artist: "Daft Punk feat. Julian Casablancas",
                albumTitle: "Random Access Memories",
                artworkURL: nil,
                previewURL: nil
            ),
            SongListItem(id: "2", title: "Get Lucky", artist: "Daft Punk", albumTitle: "Random Access Memories"),
            SongListItem(id: "3", title: "Around the World", artist: "Daft Punk", albumTitle: "Homework"),
        ],
        startAt: 0
    )
    return NavigationStack {
        PlayerView(playbackQueue: queue)
    }
}
