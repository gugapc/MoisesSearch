//
//  SongsHomeViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@MainActor
struct SongsHomeViewSnapshotTests {

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func songsHomeView_whenDefaultCatalog_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let viewModel = SongsHomeViewModel()
        let sut = createSongsHomeSut(viewModel: viewModel, size: size, scheme: scheme)

        let schemeName = scheme == .dark ? "dark" : "light"
        let sizeName = sizeName(for: size)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 900)),
            named: "\(schemeName)_\(sizeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songsHomeView_whenSearchHasNoMatches_rendersCorrectly(scheme: ColorScheme) {
        let viewModel = SongsHomeViewModel()
        viewModel.searchText = "∂ⁿø-matches-xyz"
        viewModel.applySearchQuery()

        let sut = createSongsHomeSut(viewModel: viewModel, size: .medium, scheme: scheme)
        let schemeName = scheme == .dark ? "dark" : "light"

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 900)),
            named: "no-results_\(schemeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func songsHomeView_whenSearchFiltersResults_rendersCorrectly(scheme: ColorScheme) {
        let viewModel = SongsHomeViewModel()
        viewModel.searchText = "Daft"
        viewModel.applySearchQuery()

        let sut = createSongsHomeSut(viewModel: viewModel, size: .medium, scheme: scheme)
        let schemeName = scheme == .dark ? "dark" : "light"

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 900)),
            named: "filtered_\(schemeName)"
        )
    }
}

extension SongsHomeViewSnapshotTests {
    fileprivate func createSongsHomeSut(
        viewModel: SongsHomeViewModel,
        size: DynamicTypeSize,
        scheme: ColorScheme
    ) -> some View {
        let background = scheme == .dark ? Color.black : Color.white
        return SongsHomeView(viewModel: viewModel)
            .environment(\.dynamicTypeSize, size)
            .environment(\.colorScheme, scheme)
            .background(background)
    }

    fileprivate func sizeName(for size: DynamicTypeSize) -> String {
        switch size {
        case .xSmall:
            "xSmall"
        case .medium:
            "medium"
        case .xxxLarge:
            "xxxLarge"
        default:
            "unsupported"
        }
    }
}
