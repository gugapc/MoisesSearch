//
//  SongRowViewTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI
import Testing
import ViewInspector
@testable import MoisesSearch

@Suite(.tags(.unit))
@MainActor
struct SongRowViewTests {

    @Test func moreMenu_isDisabled_whenCollectionIdMissing() throws {
        let sut = SongRowView(
            item: SongListItem(id: "row-menu", title: "Title", artist: "Artist"),
            onTapRow: {},
            onMore: {}
        )

        let menu = try sut.inspect().find(ViewType.Menu.self)
        #expect(try menu.isDisabled())
    }

    @Test func moreMenu_isEnabled_whenCollectionIdPresent() throws {
        let sut = SongRowView(
            item: SongListItem(
                id: "row-menu",
                title: "Title",
                artist: "Artist",
                collectionId: 123
            ),
            onTapRow: {},
            onMore: {}
        )

        let menu = try sut.inspect().find(ViewType.Menu.self)
        #expect(try menu.isDisabled() == false)
    }
}
