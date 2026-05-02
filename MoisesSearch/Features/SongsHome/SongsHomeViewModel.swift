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

    /// Shown while the active query is fetching (first page or pagination).
    var isSearchLoading: Bool = false
    /// Set when a remote search fails (empty query uses recents and clears this).
    var searchErrorMessage: String?

    /// Non-empty search field → we are in “remote search” mode (not recents stub list).
    var isRemoteSearchActive: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ObservationIgnored
    private let seedCatalog: [SongListItem]

    @ObservationIgnored
    private let songSearchRepository: any SongSearchRepository

    @ObservationIgnored
    private let pageSize = 25

    @ObservationIgnored
    private var remoteTotalResultCount: Int = 0

    @ObservationIgnored
    private var searchTask: Task<Void, Never>?

    @ObservationIgnored
    private var debounceTask: Task<Void, Never>?

    /// Delay after typing stops before calling the iTunes API (empty query still applies immediately).
    @ObservationIgnored
    private let searchDebounceNanoseconds: UInt64 = 300_000_000

    init(songSearchRepository: (any SongSearchRepository)? = nil) {
        self.songSearchRepository = songSearchRepository ?? ITunesSongSearchRepository(client: APIClient())
        seedCatalog = Self.stubCatalog
        applySearchQuery()
    }

    /// Home list = playback queue source: replace queue and open player.
    func playTrack(at index: Int) {
        guard displayedTracks.indices.contains(index) else { return }
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
            displayedTracks = seedCatalog
            searchErrorMessage = nil
            isSearchLoading = false
            remoteTotalResultCount = 0
            return
        }

        displayedTracks = []
        isSearchLoading = true
        searchErrorMessage = nil

        let query = trimmed
        searchTask = Task { @MainActor in
            await self.performRemoteSearch(query: query, resetList: true)
        }
    }

    /// Call when the last visible row appears to load the next iTunes page.
    func loadMoreSearchResultsIfNeeded(currentItem item: SongListItem) {
        guard displayedTracks.last?.id == item.id else { return }
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard displayedTracks.count < remoteTotalResultCount else { return }
        guard !isSearchLoading else { return }

        isSearchLoading = true
        Task { @MainActor in
            await self.performRemoteSearch(query: trimmed, resetList: false)
        }
    }

    func retrySearch() {
        applySearchQuery()
    }

    func onMoreTapped(for item: SongListItem) {
        // TODO: - Sheet "View album"
        _ = item
    }

    private func performRemoteSearch(query: String, resetList: Bool) async {
        let offset = resetList ? 0 : displayedTracks.count

        do {
            let page = try await songSearchRepository.searchSongs(query: query, limit: pageSize, offset: offset)
            try Task.checkCancellation()
            let latestQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard latestQuery == query else {
                isSearchLoading = false
                return
            }

            if resetList {
                displayedTracks = page.items
            } else {
                displayedTracks.append(contentsOf: page.items)
            }
            remoteTotalResultCount = page.totalResultCount
            isSearchLoading = false
            searchErrorMessage = nil
        } catch is CancellationError {
            isSearchLoading = false
        } catch {
            isSearchLoading = false
            if resetList {
                displayedTracks = []
            }
            searchErrorMessage = error.localizedDescription
        }
    }

    private static let stubCatalog: [SongListItem] = [
        SongListItem(id: "1", title: "Purple Rain", artist: "Prince"),
        SongListItem(id: "2", title: "Get Lucky", artist: "Daft Punk feat. Pharrell Williams"),
        SongListItem(id: "3", title: "Instant Crush", artist: "Daft Punk feat. Julian Casablancas"),
        SongListItem(id: "4", title: "Shape of You", artist: "Ed Sheeran"),
        SongListItem(id: "5", title: "Happier", artist: "Ed Sheeran"),
        SongListItem(id: "6", title: "Around the World", artist: "Daft Punk"),
    ]
}
