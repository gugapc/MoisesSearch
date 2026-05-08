//
//  SplashViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 08/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@Suite(.tags(.snapshot))
@MainActor
struct SplashViewSnapshotTests {

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func splashView_whenCompactWidth_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(scheme: scheme, horizontalSizeClass: .compact)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 390, height: 844)),
            named: "compact_\(schemeName)"
        )
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func splashView_whenRegularWidth_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(scheme: scheme, horizontalSizeClass: .regular)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(
            of: sut,
            as: .image(layout: .fixed(width: 1024, height: 768)),
            named: "regular_\(schemeName)"
        )
    }
}

extension SplashViewSnapshotTests {
    fileprivate func createSut(
        scheme: ColorScheme,
        horizontalSizeClass: UserInterfaceSizeClass
    ) -> some View {
        SplashView(onFinish: {})
            .environment(\.colorScheme, scheme)
            .environment(\.horizontalSizeClass, horizontalSizeClass)
    }
}
