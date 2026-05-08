//
//  AlbumDetail.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation

struct AlbumDetail: Equatable, Sendable {
    let collectionId: Int
    let title: String
    let artist: String
    let artworkURL: URL?
    let trackCount: Int?
    let tracks: [SongListItem]
}
