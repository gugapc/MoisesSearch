//
//  SongsHomeViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@Suite(.tags(.snapshot))
@MainActor
struct SongsHomeViewSnapshotTests {

    // MARK: - Default catalog (local stub)

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func songsHomeView_whenDefaultCatalog_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let viewModel = makeViewModel(repository: emptyRemotePageRepository())
        let sut = songsHomeView(viewModel: viewModel, size: size, scheme: scheme)

        assertSongsHomeSnapshot(
            sut,
            named: "\(SnapshotTestNaming.schemeName(scheme))_\(SnapshotTestNaming.sizeName(for: size))",
            testName: #function
        )
    }

    // MARK: - Search returns no matches

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songsHomeView_whenSearchHasNoMatches_rendersCorrectly(scheme: ColorScheme) async {
        let viewModel = makeViewModel(repository: emptyRemotePageRepository())

        await applyRemoteSearch(viewModel, query: "∂ⁿø-matches-xyz")
        assertRemoteSearchSettledWithoutError(viewModel)

        let sut = songsHomeView(viewModel: viewModel, size: .medium, scheme: scheme)
        assertSongsHomeSnapshot(sut, named: "no-results_\(SnapshotTestNaming.schemeName(scheme))", testName: #function)
    }

    // MARK: - Search filters to sample results

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songsHomeView_whenSearchFiltersResults_rendersCorrectly(scheme: ColorScheme) async {
        let viewModel = makeViewModel(repository: filteredSampleRepository())

        await applyRemoteSearch(viewModel, query: "Daft")
        assertRemoteSearchSettledWithoutError(viewModel)

        let sut = songsHomeView(viewModel: viewModel, size: .medium, scheme: scheme)
        assertSongsHomeSnapshot(sut, named: "filtered_\(SnapshotTestNaming.schemeName(scheme))", testName: #function)
    }

    // MARK: - Search fails

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songsHomeView_whenSearchFails_rendersErrorState(scheme: ColorScheme) async {
        let viewModel = makeViewModel(repository: failingRepository())

        await applyRemoteSearch(viewModel, query: "anything")
        #expect(!viewModel.isSearchLoading)
        #expect(viewModel.searchErrorMessage == "Network down")

        let sut = songsHomeView(viewModel: viewModel, size: .medium, scheme: scheme)
        assertSongsHomeSnapshot(sut, named: "error_\(SnapshotTestNaming.schemeName(scheme))", testName: #function)
    }

    // MARK: - Helpers

    /// Empty iTunes page: home uses the view model’s local seed catalog until a non-empty search runs.
    private func emptyRemotePageRepository() -> MockSongSearchRepository {
        MockSongSearchRepository(page: SongSearchPage(items: [], resultCount: 0))
    }

    private func filteredSampleRepository() -> MockSongSearchRepository {
        MockSongSearchRepository(
            page: SongSearchPage(items: snapshotFilteredTracks, resultCount: snapshotFilteredTracks.count)
        )
    }

    private func failingRepository() -> MockSongSearchRepository {
        MockSongSearchRepository(
            page: SongSearchPage(items: [], resultCount: 0),
            error: NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Network down"])
        )
    }

    private var snapshotFilteredTracks: [SongListItem] {
        [
            SongListItem(id: "snap-d1", title: "Get Lucky", artist: "Daft Punk feat. Pharrell Williams"),
            SongListItem(id: "snap-d2", title: "Instant Crush", artist: "Daft Punk feat. Julian Casablancas"),
            SongListItem(id: "snap-d3", title: "Around the World", artist: "Daft Punk"),
        ]
    }

    private func makeViewModel(repository: MockSongSearchRepository) -> SongsHomeViewModel {
        SongsHomeViewModel(songSearchRepository: repository)
    }

    private func applyRemoteSearch(_ viewModel: SongsHomeViewModel, query: String) async {
        viewModel.searchText = query
        viewModel.applySearchQuery()
        await waitUntil { !viewModel.isSearchLoading }
    }

    private func assertRemoteSearchSettledWithoutError(
        _ viewModel: SongsHomeViewModel,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(!viewModel.isSearchLoading, sourceLocation: sourceLocation)
        #expect(viewModel.searchErrorMessage == nil, sourceLocation: sourceLocation)
    }

    private func songsHomeView(
        viewModel: SongsHomeViewModel,
        size: DynamicTypeSize,
        scheme: ColorScheme
    ) -> some View {
        SongsHomeView(viewModel: viewModel, albumRepository: EmptyAlbumRepository())
            .snapshotEnvironment(dynamicTypeSize: size, colorScheme: scheme)
    }

    private func assertSongsHomeSnapshot(
        _ value: some View,
        named: String,
        testName: String,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) {
        assertSnapshot(
            of: value,
            as: .image(layout: .fixed(width: 390, height: 900)),
            named: named,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}
