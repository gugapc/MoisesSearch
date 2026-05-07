//
//  ITunesSongSearchRepositoryTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import Foundation
import Testing
@testable import MoisesSearch

@Suite(.tags(.unit))
struct ITunesSongSearchRepositoryTests {
    @Test func searchSongs_decodesResponse_andMapsToSongListItems() async throws {
        let json = """
        {
          "resultCount": 2,
          "results": [
            {
              "trackId": 100,
              "trackName": "Test Song",
              "artistName": "Test Artist",
              "collectionName": "Test Album",
              "artworkUrl100": "https://example.com/artwork-100.jpg",
              "previewUrl": "https://example.com/preview-100.m4a"
            },
            {
              "trackId": 200,
              "trackName": "Another",
              "artistName": "Band"
            }
          ]
        }
        """.data(using: .utf8)!

        let session = URLSessionMock()
        session.data = json
        session.response = HTTPURLResponse(
            url: URL(string: "https://itunes.apple.com/search")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let client = APIClient(session: session)
        let sut = ITunesSongSearchRepository(client: client)

        let page = try await sut.searchSongs(query: "test", limit: 25)

        #expect(page.resultCount == 2)
        #expect(page.items.count == 2)
        #expect(
            page.items[0]
                == SongListItem(
                    id: "100",
                    title: "Test Song",
                    artist: "Test Artist",
                    albumTitle: "Test Album",
                    artworkURL: URL(string: "https://example.com/artwork-100.jpg"),
                    previewURL: URL(string: "https://example.com/preview-100.m4a")
                )
        )
        #expect(page.items[1] == SongListItem(id: "200", title: "Another", artist: "Band"))
        #expect(page.items[1].albumTitle == nil)
    }

    @Test func searchSongs_mapsArtworkUrl60_whenArtworkUrl100Missing() async throws {
        let json = """
        {
          "resultCount": 1,
          "results": [
            {
              "trackId": 42,
              "trackName": "Song",
              "artistName": "Artist",
              "artworkUrl60": "https://example.com/small.jpg",
              "previewUrl": "https://example.com/p.m4a"
            }
          ]
        }
        """.data(using: .utf8)!

        let session = URLSessionMock()
        session.data = json
        session.response = HTTPURLResponse(
            url: URL(string: "https://itunes.apple.com/search")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let sut = ITunesSongSearchRepository(client: APIClient(session: session))
        let page = try await sut.searchSongs(query: "q", limit: 25)

        #expect(page.items.count == 1)
        #expect(
            page.items[0]
                == SongListItem(
                    id: "42",
                    title: "Song",
                    artist: "Artist",
                    artworkURL: URL(string: "https://example.com/small.jpg"),
                    previewURL: URL(string: "https://example.com/p.m4a")
                )
        )
    }
}
