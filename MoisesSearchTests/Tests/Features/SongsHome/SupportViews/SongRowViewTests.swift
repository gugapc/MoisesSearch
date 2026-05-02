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

    @Test func moreMenu_exposesViewAlbumAction_andTappingInvokesOnMore() throws {
        let rowId = "row-menu"
        var didTapMore = false

        let sut = SongRowView(
            item: SongListItem(id: rowId, title: "Title", artist: "Artist"),
            onTapRow: {},
            onMore: { didTapMore = true }
        )

        let viewAlbumButton = try sut.inspect()
            .find(ViewType.Menu.self)
            .find(viewWithAccessibilityIdentifier: "song_row_view_album_\(rowId)")
            .button()

        try viewAlbumButton.tap()
        #expect(didTapMore)
    }
}
