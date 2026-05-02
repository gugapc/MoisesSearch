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

    @ObservationIgnored
    private let seedCatalog: [SongListItem]

    init() {
        seedCatalog = Self.stubCatalog
        applySearchQuery()
    }

    /// Home list = playback queue source: replace queue and open player.
    func playTrack(at index: Int) {
        guard displayedTracks.indices.contains(index) else { return }
        playbackQueue.replace(with: displayedTracks, startAt: index)
        navigationPath.append(AppRoute.player)
    }

    func applySearchQuery() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            displayedTracks = seedCatalog
        } else {
            displayedTracks = seedCatalog.filter {
                $0.title.lowercased().contains(query) || $0.artist.lowercased().contains(query)
            }
        }
    }

    func onMoreTapped(for item: SongListItem) {
        // TODO: - Sheet "View album"
        _ = item
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
