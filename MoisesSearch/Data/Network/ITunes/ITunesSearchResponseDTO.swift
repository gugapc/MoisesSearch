//
//  ITunesSearchResponseDTO.swift
//  MoisesSearch
//

import Foundation

struct ITunesSearchResponseDTO: Decodable, Sendable {
    let resultCount: Int
    let results: [ITunesSongResultDTO]
}

struct ITunesSongResultDTO: Decodable, Sendable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let collectionName: String?
    let collectionId: Int?
    let artworkUrl60: String?
    let artworkUrl100: String?
    let previewUrl: String?

    func toSongListItem() -> SongListItem {
        let artworkString = artworkUrl100 ?? artworkUrl60
        let artworkURL = artworkString.flatMap { URL(string: $0) }
        let previewURL = previewUrl.flatMap { URL(string: $0) }
        return SongListItem(
            id: String(trackId),
            title: trackName,
            artist: artistName,
            albumTitle: collectionName,
            collectionId: collectionId,
            artworkURL: artworkURL,
            previewURL: previewURL
        )
    }
}
