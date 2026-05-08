//
//  AlbumViewModel.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation

@MainActor
@Observable
final class AlbumViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded(AlbumDetail)
        case failed(String)
    }

    /// Mutated by `load()` and the snapshot test seam — production callers go through `load()` only.
    var state: LoadState = .idle

    @ObservationIgnored let collectionId: Int
    @ObservationIgnored private let repository: any AlbumRepository
    /// Injected by the destination closure in `SongsHomeView`. Routes "play this list"
    /// to whichever screen owns the playback queue (today, `SongsHomeViewModel`).
    @ObservationIgnored private let onPlayTracks: ([SongListItem], Int) -> Void

    init(
        collectionId: Int,
        repository: any AlbumRepository,
        onPlayTracks: @escaping ([SongListItem], Int) -> Void
    ) {
        self.collectionId = collectionId
        self.repository = repository
        self.onPlayTracks = onPlayTracks
    }

    func load() async {
        state = .loading
        do {
            let detail = try await repository.fetchAlbum(collectionId: collectionId)
            try Task.checkCancellation()
            state = .loaded(detail)
        } catch is CancellationError {
            // View disappeared mid-flight; leave state alone — VM is being torn down anyway.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func playTrack(at index: Int) {
        guard case .loaded(let detail) = state,
              detail.tracks.indices.contains(index)
        else { return }
        onPlayTracks(detail.tracks, index)
    }
}
