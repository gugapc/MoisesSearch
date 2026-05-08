//
//  ITunesAlbumRepositoryTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation
import Testing
@testable import MoisesSearch

@Suite(.tags(.unit))
struct ITunesAlbumRepositoryTests {
    @Test func fetchAlbum_decodesCollectionAndPartitionsTracks() async throws {
        let json = """
        {
          "resultCount": 4,
          "results": [
            {
              "wrapperType": "collection",
              "collectionId": 555,
              "collectionName": "Random Access Memories",
              "artistName": "Daft Punk",
              "artworkUrl100": "https://example.com/cover.jpg",
              "trackCount": 3
            },
            {
              "wrapperType": "track",
              "trackId": 1,
              "trackName": "Give Life Back to Music",
              "artistName": "Daft Punk",
              "artworkUrl100": "https://example.com/t1.jpg",
              "previewUrl": "https://example.com/t1.m4a"
            },
            {
              "wrapperType": "track",
              "trackId": 2,
              "trackName": "Get Lucky",
              "artistName": "Daft Punk",
              "artworkUrl100": "https://example.com/t2.jpg"
            },
            {
              "wrapperType": "track",
              "trackId": 3,
              "trackName": "Lose Yourself to Dance",
              "artistName": "Daft Punk"
            }
          ]
        }
        """.data(using: .utf8)!

        let session = URLSessionMock()
        session.data = json
        session.response = HTTPURLResponse(
            url: URL(string: "https://itunes.apple.com/lookup")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let sut = ITunesAlbumRepository(client: APIClient(session: session))

        let detail = try await sut.fetchAlbum(collectionId: 555)

        #expect(detail.collectionId == 555)
        #expect(detail.title == "Random Access Memories")
        #expect(detail.artist == "Daft Punk")
        #expect(detail.artworkURL == URL(string: "https://example.com/cover.jpg"))
        #expect(detail.trackCount == 3)
        #expect(detail.tracks.count == 3)
        #expect(detail.tracks.map(\.id) == ["1", "2", "3"])
        #expect(detail.tracks[0].title == "Give Life Back to Music")
        #expect(detail.tracks[0].albumTitle == "Random Access Memories")
        #expect(detail.tracks[0].collectionId == 555)
        #expect(detail.tracks[0].previewURL == URL(string: "https://example.com/t1.m4a"))
        #expect(detail.tracks[2].previewURL == nil)
        #expect(detail.tracks[2].artworkURL == nil)
    }

    @Test func fetchAlbum_skipsTrackRowsMissingRequiredFields() async throws {
        let json = """
        {
          "resultCount": 3,
          "results": [
            {
              "wrapperType": "collection",
              "collectionId": 11,
              "collectionName": "A",
              "artistName": "X"
            },
            {
              "wrapperType": "track",
              "trackName": "Missing trackId",
              "artistName": "X"
            },
            {
              "wrapperType": "track",
              "trackId": 99,
              "trackName": "Valid",
              "artistName": "X"
            }
          ]
        }
        """.data(using: .utf8)!

        let session = URLSessionMock()
        session.data = json
        session.response = HTTPURLResponse(
            url: URL(string: "https://itunes.apple.com/lookup")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let sut = ITunesAlbumRepository(client: APIClient(session: session))

        let detail = try await sut.fetchAlbum(collectionId: 11)

        #expect(detail.tracks.map(\.id) == ["99"])
    }

    @Test func fetchAlbum_throwsMissingExpectedData_whenCollectionRowAbsent() async throws {
        let json = """
        {
          "resultCount": 1,
          "results": [
            {
              "wrapperType": "track",
              "trackId": 1,
              "trackName": "Lonely",
              "artistName": "Solo"
            }
          ]
        }
        """.data(using: .utf8)!

        let session = URLSessionMock()
        session.data = json
        session.response = HTTPURLResponse(
            url: URL(string: "https://itunes.apple.com/lookup")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let sut = ITunesAlbumRepository(client: APIClient(session: session))

        do {
            _ = try await sut.fetchAlbum(collectionId: 999)
            Issue.record("expected fetchAlbum to throw")
        } catch let error as APIError {
            #expect(error == .missingExpectedData("album collection row"))
        } catch {
            Issue.record("unexpected error type: \(type(of: error))")
        }
    }
}
