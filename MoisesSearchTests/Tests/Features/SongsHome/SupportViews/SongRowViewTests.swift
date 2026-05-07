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

@MainActor
struct SongRowViewTests {

    @Test func moreMenu_isDisabled_pendingAlbumRoute() throws {
        // The More menu is intentionally disabled until the album route is implemented;
        // see `SongRowView.moreButton` TODO. When that ships, drop `.disabled(true)` and
        // re-add a tap-invokes-onMore assertion.
        let sut = SongRowView(
            item: SongListItem(id: "row-menu", title: "Title", artist: "Artist"),
            onTapRow: {},
            onMore: {}
        )

        let menu = try sut.inspect().find(ViewType.Menu.self)
        #expect(try menu.isDisabled())
    }
}
