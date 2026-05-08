//
//  MoisesSearchApp.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import SwiftData
import SwiftUI

@main
struct MoisesSearchApp: App {
    private let modelContainer: ModelContainer
    private let albumRepository: any AlbumRepository

    @State private var homeViewModel: SongsHomeViewModel

    init() {
        do {
            modelContainer = try ModelContainer(
                for: PlayedTrackEntity.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            // Deliberate fail-fast: a corrupt SwiftData store is unrecoverable here and warrants reinstall,
            // not silent degradation to in-memory (which would lose recents without the user knowing).
            fatalError("Could not open SwiftData store: \(error)")
        }
        let history = SwiftDataPlaybackHistoryRepository(modelContext: ModelContext(modelContainer))
        albumRepository = ITunesAlbumRepository(client: APIClient())
        _homeViewModel = State(wrappedValue: SongsHomeViewModel(playbackHistoryRepository: history))
    }

    var body: some Scene {
        WindowGroup {
            SongsHomeView(viewModel: homeViewModel, albumRepository: albumRepository)
        }
        .modelContainer(modelContainer)
    }
}
