//
//  SnapshotRecording.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation
import SnapshotTesting

/// Centralized toggle for re-recording every snapshot baseline.
///
/// Set the `RECORD_SNAPSHOTS` env var in your test scheme (or on the `xcodebuild test`
/// invocation) to flip swift-snapshot-testing into recording mode for the whole test
/// process — no per-test changes required. Unset to validate against recorded baselines.
///
///     RECORD_SNAPSHOTS=1 xcodebuild test ...   # records everything
///     xcodebuild test ...                      # validates against baselines
enum SnapshotRecording {
    /// Idempotent: the lazy `let` fires the first time it's referenced. Reads the env var
    /// once and flips `SnapshotTesting.isRecording` if present.
    static let bootstrap: Void = {
        if ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] != nil {
            SnapshotTesting.isRecording = false
        }
    }()
}
