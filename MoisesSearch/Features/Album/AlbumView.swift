//
//  AlbumView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import SwiftUI

struct AlbumView: View {
    @State private var viewModel: AlbumViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(
        collectionId: Int,
        repository: any AlbumRepository,
        onPlayTracks: @escaping ([SongListItem], Int) -> Void
    ) {
        _viewModel = State(initialValue: AlbumViewModel(
            collectionId: collectionId,
            repository: repository,
            onPlayTracks: onPlayTracks
        ))
    }

    /// Test seam: lets snapshot/unit tests inject a pre-configured view model
    /// (e.g. a fixed `LoadState`).
    init(viewModel: AlbumViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView {
            content
                .padding(.bottom, 40)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Snapshot/test seams set a non-idle state directly; only kick off the network
            // when there's nothing to render yet.
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }

    private var navigationTitle: String {
        if case .loaded(let detail) = viewModel.state {
            return detail.title
        }
        return ""
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingState
        case .loaded(let detail):
            loadedState(detail)
        case .failed(let message):
            failedState(message)
        }
    }

    private var loadingState: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.top, 100)
            .accessibilityIdentifier("album_loading")
    }

    private func failedState(_ message: String) -> some View {
        RetryableErrorView(message: message) {
            Task { await viewModel.load() }
        }
        .accessibilityIdentifier("album_failed")
    }

    private func loadedState(_ detail: AlbumDetail) -> some View {
        VStack(spacing: isRegularWidth ? 32 : 20) {
            hero(detail)
            tracks(detail)
        }
        .padding(.top, isRegularWidth ? 32 : 16)
        .padding(.horizontal, isRegularWidth ? 48 : 16)
        .accessibilityIdentifier("album_loaded")
    }

    private func hero(_ detail: AlbumDetail) -> some View {
        VStack(spacing: isRegularWidth ? 16 : 12) {
            artwork(url: detail.artworkURL)
            VStack(spacing: 4) {
                Text(detail.title)
                    .font(isRegularWidth ? .system(size: 36, weight: .bold) : .title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text(detail.artist)
                    .font(isRegularWidth ? .title3 : .subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func artwork(url: URL?) -> some View {
        let side: CGFloat = isRegularWidth ? 280 : 220
        return Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        artworkPlaceholder(showProgress: true)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        artworkPlaceholder(showProgress: false)
                    @unknown default:
                        artworkPlaceholder(showProgress: false)
                    }
                }
            } else {
                artworkPlaceholder(showProgress: false)
            }
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func artworkPlaceholder(showProgress: Bool) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.primary.opacity(0.12))
            .overlay {
                if showProgress {
                    ProgressView()
                } else {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                }
            }
    }

    private func tracks(_ detail: AlbumDetail) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(detail.tracks.enumerated()), id: \.element.id) { index, track in
                AlbumTrackRowView(track: track) {
                    viewModel.playTrack(at: index)
                }
            }
        }
    }
}
