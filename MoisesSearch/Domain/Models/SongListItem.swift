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
    let artworkURL: URL?
    let previewURL: URL?

    init(id: String, title: String, artist: String, artworkURL: URL? = nil, previewURL: URL? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.previewURL = previewURL
    }
}
