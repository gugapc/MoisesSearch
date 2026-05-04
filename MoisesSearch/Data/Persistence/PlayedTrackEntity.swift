//
//  PlayedTrackEntity.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation
import SwiftData

@Model
final class PlayedTrackEntity {
    @Attribute(.unique) var appleTrackId: String
    var title: String
    var artist: String
    var playedAt: Date
    var artworkURLString: String?
    var previewURLString: String?

    init(
        appleTrackId: String,
        title: String,
        artist: String,
        playedAt: Date,
        artworkURLString: String? = nil,
        previewURLString: String? = nil
    ) {
        self.appleTrackId = appleTrackId
        self.title = title
        self.artist = artist
        self.playedAt = playedAt
        self.artworkURLString = artworkURLString
        self.previewURLString = previewURLString
    }

    static func from(_ item: SongListItem, playedAt: Date) -> PlayedTrackEntity {
        PlayedTrackEntity(
            appleTrackId: item.id,
            title: item.title,
            artist: item.artist,
            playedAt: playedAt,
            artworkURLString: item.artworkURL?.absoluteString,
            previewURLString: item.previewURL?.absoluteString
        )
    }

    func toSongListItem() -> SongListItem {
        SongListItem(
            id: appleTrackId,
            title: title,
            artist: artist,
            artworkURL: artworkURLString.flatMap(URL.init(string:)),
            previewURL: previewURLString.flatMap(URL.init(string:))
        )
    }
}
