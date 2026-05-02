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
}
