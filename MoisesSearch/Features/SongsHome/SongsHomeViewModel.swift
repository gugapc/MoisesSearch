//
//  SongsHomeViewModel.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI

@MainActor
@Observable
final class SongsHomeViewModel {
    var searchText: String = ""
    var navigationPath = NavigationPath()

    let playbackQueue = PlaybackQueue()

    private(set) var displayedTracks: [SongListItem] = []

    /// Shown while a remote search is in flight.
    var isSearchLoading: Bool = false
    /// Set when a remote search fails (empty query uses recents and clears this).
    var searchErrorMessage: String?

    /// Non-empty search field → we are in “remote search” mode (not recents stub list).
    var isRemoteSearchActive: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ObservationIgnored
    private let seedCatalog: [SongListItem] = []

    @ObservationIgnored
    private let songSearchRepository: any SongSearchRepository

    @ObservationIgnored
    private let playbackHistoryRepository: any PlaybackHistoryRepository

    @ObservationIgnored
    private let searchResultLimit = 25

    @ObservationIgnored
    private let recentListLimit: Int

    @ObservationIgnored
    private var searchTask: Task<Void, Never>?

    @ObservationIgnored
    private var debounceTask: Task<Void, Never>?

    /// Delay after typing stops before calling the iTunes API (empty query still applies immediately).
    @ObservationIgnored
    private let searchDebounceNanoseconds: UInt64 = 300_000_000

    init(
        songSearchRepository: (any SongSearchRepository)? = nil,
        playbackHistoryRepository: (any PlaybackHistoryRepository)? = nil,
        recentListLimit: Int = 50
    ) {
        self.songSearchRepository = songSearchRepository ?? ITunesSongSearchRepository(client: APIClient())
        self.playbackHistoryRepository = playbackHistoryRepository ?? EmptyPlaybackHistoryRepository()
        self.recentListLimit = recentListLimit
        applySearchQuery()
    }

    /// Home list = playback queue source: replace queue and open player.
    func playTrack(at index: Int) {
        guard displayedTracks.indices.contains(index) else { return }
        let item = displayedTracks[index]
        try? playbackHistoryRepository.recordPlayback(item, playedAt: Date())
        playbackQueue.replace(with: displayedTracks, startAt: index)
        navigationPath.append(AppRoute.player)
    }

    /// Call from the view when `searchText` changes. Remote search is debounced; clearing the field updates recents immediately.
    func scheduleDebouncedSearch() {
        debounceTask?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            applySearchQuery()
            return
        }
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: searchDebounceNanoseconds)
            guard !Task.isCancelled else { return }
            applySearchQuery()
        }
    }

    func applySearchQuery() {
        searchTask?.cancel()

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchErrorMessage = nil
            isSearchLoading = false
            do {
                let recents = try playbackHistoryRepository.recentTracks(limit: recentListLimit)
                displayedTracks = recents.isEmpty ? seedCatalog : recents
            } catch {
                displayedTracks = seedCatalog
            }
            return
        }

        displayedTracks = []
        isSearchLoading = true
        searchErrorMessage = nil

        let query = trimmed
        searchTask = Task { @MainActor in
            await self.performRemoteSearch(query: query)
        }
    }

    func retrySearch() {
        applySearchQuery()
    }

    func onMoreTapped(for item: SongListItem) {
        // TODO: - Sheet "View album"
        _ = item
    }

    private func performRemoteSearch(query: String) async {
        do {
            let page = try await songSearchRepository.searchSongs(query: query, limit: searchResultLimit)
            try Task.checkCancellation()
            let latestQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard latestQuery == query else {
                isSearchLoading = false
                return
            }

            displayedTracks = page.items
            isSearchLoading = false
            searchErrorMessage = nil
        } catch is CancellationError {
            let latestQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard latestQuery == query else { return }
            isSearchLoading = false
        } catch {
            let latestQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard latestQuery == query else {
                isSearchLoading = false
                return
            }
            isSearchLoading = false
            displayedTracks = []
            searchErrorMessage = error.localizedDescription
        }
    }
}
