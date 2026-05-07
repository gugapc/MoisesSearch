//
//  PlayerBottomChromeViewSnapshotTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 06/05/26.
//

import SwiftUI
import SnapshotTesting
import Testing
@testable import MoisesSearch

@MainActor
struct PlayerBottomChromeViewSnapshotTests {

    // Note: the play/pause button uses `.buttonStyle(.glass)`, whose Liquid Glass capsule
    // is composited by the system render server — a pipeline the snapshot rasterizer
    // bypasses, so the capsule appears transparent here. Layout, labels, transport state,
    // and timing remain fully validated; the glass effect is verified visually at runtime.

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func playerBottomChrome_whenPlaying_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(progress: 0.5, isPlaying: true, size: size, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(of: sut, as: .image, named: "playing_\(schemeName)_\(sizeName)")
    }

    @Test(arguments: [DynamicTypeSize.xSmall, DynamicTypeSize.medium, DynamicTypeSize.xxxLarge], [ColorScheme.dark, ColorScheme.light])
    func playerBottomChrome_whenPaused_rendersCorrectly(size: DynamicTypeSize, scheme: ColorScheme) {
        let sut = createSut(progress: 0.5, isPlaying: false, size: size, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)
        let sizeName = SnapshotTestNaming.sizeName(for: size)

        assertSnapshot(of: sut, as: .image, named: "paused_\(schemeName)_\(sizeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerBottomChrome_whenProgressIsAtStart_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(progress: 0, isPlaying: false, size: .medium, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "progress-start_\(schemeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerBottomChrome_whenProgressIsAtMid_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(progress: 0.5, isPlaying: true, size: .medium, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "progress-mid_\(schemeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerBottomChrome_whenProgressIsAtEnd_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(progress: 1, isPlaying: false, size: .medium, scheme: scheme)

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "progress-end_\(schemeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerBottomChrome_whenTransportControlsDisabled_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(
            progress: 0.5,
            isPlaying: true,
            size: .medium,
            scheme: scheme,
            hasPrevious: false,
            hasNext: false
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "transport-disabled_\(schemeName)")
    }

    @Test(arguments: [ColorScheme.dark, ColorScheme.light])
    func playerBottomChrome_whenLayoutDirectionIsRightToLeft_rendersCorrectly(scheme: ColorScheme) {
        let sut = createSut(
            progress: 0.5,
            isPlaying: true,
            size: .medium,
            scheme: scheme,
            layoutDirection: .rightToLeft
        )

        let schemeName = SnapshotTestNaming.schemeName(scheme)

        assertSnapshot(of: sut, as: .image, named: "rtl_\(schemeName)")
    }
}

extension PlayerBottomChromeViewSnapshotTests {
    fileprivate func createSut(
        progress: Double,
        isPlaying: Bool,
        size: DynamicTypeSize,
        scheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight,
        hasPrevious: Bool = true,
        hasNext: Bool = true
    ) -> some View {
        let background = scheme == .dark ? Color.black : Color.white
        return BottomChromeHost(
            progress: progress,
            isPlaying: isPlaying,
            hasPrevious: hasPrevious,
            hasNext: hasNext
        )
        .environment(\.dynamicTypeSize, size)
        .environment(\.colorScheme, scheme)
        .environment(\.layoutDirection, layoutDirection)
        .background(background)
        .frame(width: 390)
    }
}

/// Lightweight host so the chrome view can read deterministic `@Binding` values at snapshot time
/// without bringing in `PlayerViewModel`'s ticker / async state.
private struct BottomChromeHost: View {
    @State var progress: Double
    @State var isPlaying: Bool
    let hasPrevious: Bool
    let hasNext: Bool

    var body: some View {
        PlayerBottomChromeView(
            trackTitle: "Instant Crush",
            artistName: "Daft Punk feat. Julian Casablancas",
            progress: $progress,
            isPlaying: $isPlaying,
            durationSeconds: 220,
            onPrevious: {},
            onNext: {},
            onScrubbingChanged: { _ in },
            hasPrevious: hasPrevious,
            hasNext: hasNext
        )
    }
}
