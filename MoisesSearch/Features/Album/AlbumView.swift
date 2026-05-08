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
        let alignment: HorizontalAlignment = isRegularWidth ? .leading : .center

        return VStack(alignment: alignment, spacing: 40) {
            hero(detail)
            tracks(detail)
        }
        .padding(.top, isRegularWidth ? 32 : 16)
        .padding(.horizontal, isRegularWidth ? 48 : 16)
        .accessibilityIdentifier("album_loaded")
    }

    @ViewBuilder
    private func hero(_ detail: AlbumDetail) -> some View {
        if isRegularWidth {
            HStack(spacing: 34) {
                artwork(url: detail.artworkURL)
                albumTexts(detail)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 16) {
                artwork(url: detail.artworkURL)
                albumTexts(detail)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func albumTexts(_ detail: AlbumDetail) -> some View {
        let spacing: CGFloat = isRegularWidth ? 6 : 4
        return VStack(alignment: isRegularWidth ? .leading : .center, spacing: spacing) {
            Text(detail.title)
                .font(isRegularWidth ? .largeTitle.bold() : .title2.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(isRegularWidth ? .leading : .center)

            Text(detail.artist)
                .font(isRegularWidth ? .title2 : .subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(isRegularWidth ? .leading : .center)
        }
    }

    private func artwork(url: URL?) -> some View {
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
        .frame(width: 120, height: 120)
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
        let spacing: CGFloat = isRegularWidth ? 12 : 8

        return LazyVStack(spacing: spacing) {
            ForEach(Array(detail.tracks.enumerated()), id: \.element.id) { index, track in
                AlbumTrackRowView(track: track) {
                    viewModel.playTrack(at: index)
                }
            }
        }
    }
}
