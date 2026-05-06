//
//  PlayerViewModel.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 05/05/26.
//

import Foundation

@MainActor
@Observable
final class PlayerViewModel {
    let playbackQueue: PlaybackQueue

    var isPlaying: Bool = false
    var progress: Double = 0
    var isScrubbing: Bool = false

    // TODO: replace with `trackTimeMillis` once AVPlayer streams real preview audio.
    let placeholderDuration: Double
    let tickInterval: Duration

    init(
        playbackQueue: PlaybackQueue,
        placeholderDuration: Double = 210,
        tickInterval: Duration = .milliseconds(500)
    ) {
        self.playbackQueue = playbackQueue
        self.placeholderDuration = placeholderDuration
        self.tickInterval = tickInterval
    }

    var canAdvance: Bool { playbackQueue.canAdvance }
    var canRewind: Bool { playbackQueue.canRewind }
    var currentTrack: SongListItem? { playbackQueue.currentTrack }

    func togglePlayPause() {
        isPlaying.toggle()
    }

    func next() {
        playbackQueue.advanceToNext()
        resetProgress()
    }

    func previous() {
        playbackQueue.skipToPrevious()
        resetProgress()
    }

    func jumpToTrack(at index: Int) {
        playbackQueue.jumpToTrack(at: index)
        resetProgress()
    }

    func beginScrubbing() {
        isScrubbing = true
    }

    func endScrubbing() {
        isScrubbing = false
    }

    func runTickerLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: tickInterval)
            if Task.isCancelled { return }
            tick()
        }
    }

    func tick() {
        guard isPlaying, !isScrubbing, progress < 1 else { return }
        progress = min(1, progress + tickIntervalSeconds / placeholderDuration)
    }

    private func resetProgress() {
        progress = 0
    }

    private var tickIntervalSeconds: Double {
        tickInterval / .seconds(1)
    }
}
