//
//  SongsHomeViewModelPlaybackTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation
import Testing
@testable import MoisesSearch

@MainActor
struct SongsHomeViewModelPlaybackTests {
    @Test func emptyQuery_usesRepositoryRecents_whenNonEmpty() {
        let recent = SongListItem(id: "99", title: "Recent", artist: "Artist")
        let history = MockPlaybackHistoryRepository(recentToReturn: [recent])
        let vm = SongsHomeViewModel(playbackHistoryRepository: history)

        vm.searchText = ""
        vm.applySearchQuery()

        #expect(vm.displayedTracks == [recent])
    }

    @Test func emptyQuery_showsEmptyList_whenRepositoryReturnsEmpty() {
        let history = MockPlaybackHistoryRepository(recentToReturn: [])
        let vm = SongsHomeViewModel(playbackHistoryRepository: history)

        vm.searchText = ""
        vm.applySearchQuery()

        #expect(vm.displayedTracks.isEmpty)
    }

    @Test func emptyQuery_showsEmptyList_whenRepositoryThrows() {
        let history = MockPlaybackHistoryRepository(recentToReturn: [], shouldThrowOnRecent: true)
        let vm = SongsHomeViewModel(playbackHistoryRepository: history)

        vm.searchText = ""
        vm.applySearchQuery()

        #expect(vm.displayedTracks.isEmpty)
    }

    @Test func playTrack_recordsPlayback() async {
        let history = MockPlaybackHistoryRepository()
        let page = SongSearchPage(
            items: [SongListItem(id: "7", title: "Play Me", artist: "Band")],
            resultCount: 1
        )
        let search = MockSongSearchRepository(page: page, error: nil)
        let vm = SongsHomeViewModel(songSearchRepository: search, playbackHistoryRepository: history)

        vm.searchText = "anything"
        vm.applySearchQuery()

        await waitUntil { vm.displayedTracks.count == 1 }

        #expect(vm.displayedTracks.count == 1)
        vm.playTrack(at: 0)

        #expect(history.recordCalls.count == 1)
        #expect(history.recordCalls[0].0.id == "7")
    }
}
