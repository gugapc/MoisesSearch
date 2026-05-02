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
    func toSongListItem() -> SongListItem {
        SongListItem(id: String(trackId), title: trackName, artist: artistName)
    }
}
