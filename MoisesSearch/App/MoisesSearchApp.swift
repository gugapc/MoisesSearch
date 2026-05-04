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

    @State private var homeViewModel: SongsHomeViewModel

    init() {
        do {
            modelContainer = try ModelContainer(
                for: PlayedTrackEntity.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Could not open SwiftData store: \(error)")
        }
        let history = SwiftDataPlaybackHistoryRepository(modelContext: ModelContext(modelContainer))
        _homeViewModel = State(wrappedValue: SongsHomeViewModel(playbackHistoryRepository: history))
    }

    var body: some Scene {
        WindowGroup {
            SongsHomeView(viewModel: homeViewModel)
        }
        .modelContainer(modelContainer)
    }
}
