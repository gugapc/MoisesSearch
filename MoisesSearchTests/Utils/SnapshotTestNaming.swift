//
//  SnapshotTestNaming.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import SwiftUI

/// Segments for snapshot `named:` so schemes and dynamic type sizes stay consistent across tests.
enum SnapshotTestNaming {
    static func schemeName(_ scheme: ColorScheme) -> String {
        _ = SnapshotRecording.bootstrap
        return scheme == .dark ? "dark" : "light"
    }

    static func sizeName(for size: DynamicTypeSize) -> String {
        switch size {
        case .xSmall: "xSmall"
        case .medium: "medium"
        case .xxxLarge: "xxxLarge"
        default: "unsupported"
        }
    }
}
