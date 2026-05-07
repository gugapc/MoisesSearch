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
    @ObservationIgnored let playbackQueue: PlaybackQueue

    var isPlaying: Bool = false
    var progress: Double = 0
    @ObservationIgnored var isScrubbing: Bool = false

    // TODO: replace with `trackTimeMillis` once AVPlayer streams real preview audio.
    @ObservationIgnored let placeholderDuration: Double
    @ObservationIgnored let tickInterval: Duration

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

    var navigationAlbumTitle: String {
        guard let track = currentTrack else {
            return String(localized: "Player")
        }
        if let album = track.albumTitle, !album.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return album
        }
        return track.title
    }

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
        guard index != playbackQueue.currentIndex else { return }
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
