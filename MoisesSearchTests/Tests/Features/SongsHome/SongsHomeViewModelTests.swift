//
//  SongsHomeViewModelTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation
import Testing
@testable import MoisesSearch

@Suite(.tags(.unit))
@MainActor
struct SongsHomeViewModelTests {

    // MARK: - applySearchQuery (remote)

    @Test
    func testApplySearchQuery_whenSuccess_updatesDisplayedTracksAndClearsError() async {
        let sut = makeSUT()

        sut.searchText = "any"
        sut.applySearchQuery()
        await waitUntil { !sut.isSearchLoading }

        assertRemoteSearchSuccess(sut, tracks: defaultRemoteTracks)
    }

    @Test
    func testApplySearchQuery_whenRepositoryThrows_clearsTracksAndSetsLocalizedErrorMessage() async {
        let sut = makeSUT(repository: failingRepository())

        sut.searchText = "query"
        sut.applySearchQuery()
        await waitUntil { !sut.isSearchLoading }

        assertRemoteSearchFailure(sut, localizedMessage: "Network down")
    }

    // MARK: - applySearchQuery (empty / stub)

    @Test
    func testApplySearchQuery_whenQueryEmptyAfterInit_showsStubCatalogWithoutInvokingRepository() {
        let sut = makeSUT(repository: throwIfInvokedRepository())

        assertStubCatalog(sut)
    }

    @Test
    func testApplySearchQuery_whenQueryClearedAfterSuccess_restoresStubCatalogAndClearsError() async {
        let sut = makeSUT()

        sut.searchText = "find me"
        sut.applySearchQuery()
        await waitUntil { !sut.isSearchLoading }
        assertRemoteSearchSuccess(sut, tracks: defaultRemoteTracks)

        sut.searchText = ""
        sut.applySearchQuery()

        assertStubCatalog(sut)
    }

    // MARK: - Helpers (factories)

    private var defaultRemoteTracks: [SongListItem] {
        [
            SongListItem(id: "a", title: "Alpha", artist: "Artist A"),
            SongListItem(id: "b", title: "Beta", artist: "Artist B"),
        ]
    }

    private func makeSUT(repository: MockSongSearchRepository? = nil) -> SongsHomeViewModel {
        SongsHomeViewModel(songSearchRepository: repository ?? successRepository())
    }

    private func successRepository() -> MockSongSearchRepository {
        let items = defaultRemoteTracks
        return MockSongSearchRepository(page: SongSearchPage(items: items, resultCount: items.count))
    }

    private func failingRepository() -> MockSongSearchRepository {
        MockSongSearchRepository(
            page: SongSearchPage(items: [], resultCount: 0),
            error: NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Network down"])
        )
    }

    private func throwIfInvokedRepository() -> MockSongSearchRepository {
        MockSongSearchRepository(
            page: SongSearchPage(items: [], resultCount: 0),
            error: NSError(domain: "MockShouldNotBeCalled", code: 1)
        )
    }

    // MARK: - Helpers (assertions)

    private func assertRemoteSearchSuccess(
        _ sut: SongsHomeViewModel,
        tracks: [SongListItem],
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(sut.displayedTracks == tracks, sourceLocation: sourceLocation)
        #expect(sut.searchErrorMessage == nil, sourceLocation: sourceLocation)
        #expect(sut.isSearchLoading == false, sourceLocation: sourceLocation)
    }

    private func assertRemoteSearchFailure(
        _ sut: SongsHomeViewModel,
        localizedMessage: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(sut.displayedTracks.isEmpty, sourceLocation: sourceLocation)
        #expect(sut.searchErrorMessage == localizedMessage, sourceLocation: sourceLocation)
        #expect(sut.isSearchLoading == false, sourceLocation: sourceLocation)
    }

    private func assertStubCatalog(_ sut: SongsHomeViewModel, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(sut.displayedTracks.isEmpty, sourceLocation: sourceLocation)
        #expect(sut.searchErrorMessage == nil, sourceLocation: sourceLocation)
        #expect(sut.isSearchLoading == false, sourceLocation: sourceLocation)
    }
}
