//
//  SwiftDataPlaybackHistoryRepositoryTests.swift
//  MoisesSearchTests
//

import Foundation
import SwiftData
import Testing
@testable import MoisesSearch

@Suite(.tags(.unit))
@MainActor
struct SwiftDataPlaybackHistoryRepositoryTests {
    @Test func recentTracks_returnsNewestFirst_andRespectsLimit() throws {
        let container = try ModelContainer(
            for: PlayedTrackEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let sut = SwiftDataPlaybackHistoryRepository(modelContext: context)

        let older = Date(timeIntervalSince1970: 100)
        let newer = Date(timeIntervalSince1970: 200)
        let newest = Date(timeIntervalSince1970: 300)

        try sut.recordPlayback(SongListItem(id: "a", title: "A", artist: "1"), playedAt: older)
        try sut.recordPlayback(SongListItem(id: "b", title: "B", artist: "2"), playedAt: newer)
        try sut.recordPlayback(SongListItem(id: "c", title: "C", artist: "3"), playedAt: newest)

        let all = try sut.recentTracks(limit: 10)
        #expect(all.map(\.id) == ["c", "b", "a"])

        let limited = try sut.recentTracks(limit: 2)
        #expect(limited.map(\.id) == ["c", "b"])
    }

    @Test func recordPlayback_updatesExistingTrack_andMovesToTop() throws {
        let container = try ModelContainer(
            for: PlayedTrackEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let sut = SwiftDataPlaybackHistoryRepository(modelContext: context)

        let tX = Date(timeIntervalSince1970: 50)
        let tZ = Date(timeIntervalSince1970: 100)
        let tXReplay = Date(timeIntervalSince1970: 150)

        try sut.recordPlayback(
            SongListItem(id: "x", title: "Old", artist: "Y", albumTitle: "Old Album"),
            playedAt: tX
        )
        try sut.recordPlayback(SongListItem(id: "z", title: "Zed", artist: "Z"), playedAt: tZ)

        var recent = try sut.recentTracks(limit: 10)
        #expect(recent.map(\.id) == ["z", "x"])

        try sut.recordPlayback(
            SongListItem(id: "x", title: "New", artist: "Y", albumTitle: "Updated Album"),
            playedAt: tXReplay
        )
        recent = try sut.recentTracks(limit: 10)
        #expect(recent.map(\.id) == ["x", "z"])
        #expect(recent[0].title == "New")
        #expect(recent[0].albumTitle == "Updated Album")
    }

    @Test func roundTrip_preservesOptionalFields() throws {
        let container = try ModelContainer(
            for: PlayedTrackEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let sut = SwiftDataPlaybackHistoryRepository(modelContext: context)

        let withAlbum = SongListItem(
            id: "42",
            title: "Song",
            artist: "Artist",
            albumTitle: "Album A",
            artworkURL: URL(string: "https://example.com/a.jpg"),
            previewURL: URL(string: "https://example.com/p.m4a")
        )
        let withoutAlbum = SongListItem(
            id: "43",
            title: "Other",
            artist: "Artist",
            albumTitle: nil,
            artworkURL: URL(string: "https://example.com/b.jpg"),
            previewURL: nil
        )
        try sut.recordPlayback(withAlbum, playedAt: Date(timeIntervalSince1970: 1))
        try sut.recordPlayback(withoutAlbum, playedAt: Date(timeIntervalSince1970: 2))

        let recent = try sut.recentTracks(limit: 5)
        #expect(recent.count == 2)
        #expect(recent[0] == withoutAlbum)
        #expect(recent[0].albumTitle == nil)
        #expect(recent[1] == withAlbum)
        #expect(recent[1].albumTitle == "Album A")
    }
}
