//
//  AlbumViewModelTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation
import Testing
@testable import MoisesSearch

@Suite(.tags(.unit))
@MainActor
struct AlbumViewModelTests {
    @Test func load_whenSuccess_setsLoadedState() async {
        let detail = makeDetail()
        let repo = MockAlbumRepository(album: detail)
        let recorder = PlayTracksRecorder()
        let sut = AlbumViewModel(
            collectionId: 555,
            repository: repo,
            onPlayTracks: recorder.capture
        )

        await sut.load()

        guard case .loaded(let loaded) = sut.state else {
            Issue.record("expected loaded state, got \(sut.state)")
            return
        }
        #expect(loaded.collectionId == 555)
        #expect(loaded.tracks.count == 2)
    }

    @Test func load_whenRepositoryThrows_setsFailedState() async {
        struct StubError: LocalizedError {
            var errorDescription: String? { "Network down" }
        }
        let repo = MockAlbumRepository(error: StubError())
        let recorder = PlayTracksRecorder()
        let sut = AlbumViewModel(
            collectionId: 555,
            repository: repo,
            onPlayTracks: recorder.capture
        )

        await sut.load()

        guard case .failed(let message) = sut.state else {
            Issue.record("expected failed state, got \(sut.state)")
            return
        }
        #expect(message == "Network down")
    }

    @Test func playTrack_whenLoaded_invokesPlayTracksClosure() async {
        let repo = MockAlbumRepository(album: makeDetail())
        let recorder = PlayTracksRecorder()
        let sut = AlbumViewModel(
            collectionId: 555,
            repository: repo,
            onPlayTracks: recorder.capture
        )
        await sut.load()

        sut.playTrack(at: 1)

        #expect(recorder.calls.count == 1)
        #expect(recorder.calls.first?.tracks.map(\.id) == ["1", "2"])
        #expect(recorder.calls.first?.startAt == 1)
    }

    @Test func playTrack_whenIndexOutOfRange_doesNothing() async {
        let repo = MockAlbumRepository(album: makeDetail())
        let recorder = PlayTracksRecorder()
        let sut = AlbumViewModel(
            collectionId: 555,
            repository: repo,
            onPlayTracks: recorder.capture
        )
        await sut.load()

        sut.playTrack(at: 99)

        #expect(recorder.calls.isEmpty)
    }

    @Test func playTrack_whenNotLoaded_doesNothing() {
        let repo = MockAlbumRepository()
        let recorder = PlayTracksRecorder()
        let sut = AlbumViewModel(
            collectionId: 555,
            repository: repo,
            onPlayTracks: recorder.capture
        )

        sut.playTrack(at: 0)

        #expect(recorder.calls.isEmpty)
    }

    private func makeDetail() -> AlbumDetail {
        AlbumDetail(
            collectionId: 555,
            title: "Random Access Memories",
            artist: "Daft Punk",
            artworkURL: nil,
            trackCount: 2,
            tracks: [
                SongListItem(
                    id: "1",
                    title: "Give Life Back to Music",
                    artist: "Daft Punk",
                    albumTitle: "Random Access Memories",
                    collectionId: 555
                ),
                SongListItem(
                    id: "2",
                    title: "Get Lucky",
                    artist: "Daft Punk",
                    albumTitle: "Random Access Memories",
                    collectionId: 555
                ),
            ]
        )
    }
}

/// Captures `onPlayTracks` invocations for assertion. Reference type so the closure and
/// the test both see the same `calls` array without `inout` capture gymnastics.
@MainActor
private final class PlayTracksRecorder {
    private(set) var calls: [(tracks: [SongListItem], startAt: Int)] = []

    func capture(_ tracks: [SongListItem], startAt index: Int) {
        calls.append((tracks, index))
    }
}
