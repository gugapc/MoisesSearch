//
//  SongListItem.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import Foundation

struct SongListItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artist: String
    /// Album name when known (e.g. iTunes `collectionName`); used for player navigation title.
    let albumTitle: String?
    let collectionId: Int?
    let artworkURL: URL?
    let previewURL: URL?

    init(
        id: String,
        title: String,
        artist: String,
        albumTitle: String? = nil,
        collectionId: Int? = nil,
        artworkURL: URL? = nil,
        previewURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumTitle = albumTitle
        self.collectionId = collectionId
        self.artworkURL = artworkURL
        self.previewURL = previewURL
    }
}
