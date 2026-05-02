//
//  ITunesSongSearchRepositoryTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import Foundation
import Testing
@testable import MoisesSearch

struct ITunesSongSearchRepositoryTests {
    @Test func searchSongs_decodesResponse_andMapsToSongListItems() async throws {
        let json = """
        {
          "resultCount": 2,
          "results": [
            {
              "trackId": 100,
              "trackName": "Test Song",
              "artistName": "Test Artist"
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

        let page = try await sut.searchSongs(query: "test", limit: 25, offset: 0)

        #expect(page.totalResultCount == 2)
        #expect(page.items.count == 2)
        #expect(page.items[0] == SongListItem(id: "100", title: "Test Song", artist: "Test Artist"))
        #expect(page.items[1] == SongListItem(id: "200", title: "Another", artist: "Band"))
        #expect(page.hasMorePages == false)
    }

    @Test func searchSongs_whenMoreResults_hasMorePages() async throws {
        let json = """
        {
          "resultCount": 100,
          "results": [
            { "trackId": 1, "trackName": "A", "artistName": "B" }
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
        let page = try await sut.searchSongs(query: "q", limit: 25, offset: 0)

        #expect(page.hasMorePages == true)
    }
}
