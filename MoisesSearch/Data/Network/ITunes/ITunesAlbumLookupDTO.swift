//
//  ITunesAlbumLookupDTO.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation

struct ITunesAlbumLookupResponseDTO: Decodable, Sendable {
    let resultCount: Int
    let results: [ITunesAlbumLookupItemDTO]
}

struct ITunesAlbumLookupItemDTO: Decodable, Sendable {
    let wrapperType: String
    let collectionId: Int?
    let collectionName: String?
    let artistName: String?
    let artworkUrl100: String?
    let trackCount: Int?
    let trackId: Int?
    let trackName: String?
    let previewUrl: String?
}

extension ITunesAlbumLookupResponseDTO {
    func toAlbumDetail() throws -> AlbumDetail {
        guard
            let collection = results.first(where: { $0.wrapperType == "collection" }),
            let collectionId = collection.collectionId,
            let collectionName = collection.collectionName,
            let artistName = collection.artistName
        else {
            throw APIError.missingExpectedData("album collection row")
        }

        let tracks: [SongListItem] = results
            .filter { $0.wrapperType == "track" }
            .compactMap { item in
                guard
                    let trackId = item.trackId,
                    let trackName = item.trackName,
                    let trackArtist = item.artistName
                else { return nil }
                return SongListItem(
                    id: String(trackId),
                    title: trackName,
                    artist: trackArtist,
                    albumTitle: collectionName,
                    collectionId: collectionId,
                    artworkURL: item.artworkUrl100.flatMap { URL(string: $0) },
                    previewURL: item.previewUrl.flatMap { URL(string: $0) }
                )
            }

        return AlbumDetail(
            collectionId: collectionId,
            title: collectionName,
            artist: artistName,
            artworkURL: collection.artworkUrl100.flatMap { URL(string: $0) },
            trackCount: collection.trackCount,
            tracks: tracks
        )
    }
}
