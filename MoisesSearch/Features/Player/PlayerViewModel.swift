//
//  PlayerViewModel.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 05/05/26.
//

import AVFoundation
import Foundation

@MainActor
@Observable
final class PlayerViewModel {
    @ObservationIgnored let playbackQueue: PlaybackQueue

    /// Drives AVPlayer via `didSet`. The chrome's play button toggles this through a `@Binding`,
    /// which means we *cannot* rely on `togglePlayPause()` being the only mutation site —
    /// every write must reach `player.play()` / `player.pause()`.
    var isPlaying: Bool = false {
        didSet {
            guard isPlaying != oldValue else { return }
            if isPlaying {
                configureAudioSessionIfNeeded()
                player.play()
            } else {
                player.pause()
            }
        }
    }
    /// 0...1, written by the periodic time observer (when not scrubbing) and by the slider while scrubbing.
    var progress: Double = 0
    @ObservationIgnored var isScrubbing: Bool = false

    private(set) var currentTime: TimeInterval = 0
    /// `nil` until the current item's duration has loaded
    var duration: TimeInterval?
    /// Set when the current track has no preview URL or the AVPlayerItem failed to load.
    private(set) var playbackError: String?

    @ObservationIgnored private let player = AVPlayer()
    @ObservationIgnored private var timeObserverToken: Any?
    @ObservationIgnored private var endObserverToken: NSObjectProtocol?
    /// Bumped on each track change; duration-load tasks compare against this to discard stale writes.
    @ObservationIgnored private var loadGeneration = 0
    @ObservationIgnored private var didConfigureAudioSession = false

    init(playbackQueue: PlaybackQueue) {
        self.playbackQueue = playbackQueue
        setUpTimeObserver()
        replaceCurrentTrack()
    }

    deinit {
        MainActor.assumeIsolated {
            if let token = timeObserverToken {
                player.removeTimeObserver(token)
            }
            if let token = endObserverToken {
                NotificationCenter.default.removeObserver(token)
            }
            player.pause()
        }
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
        replaceCurrentTrack()
    }

    func previous() {
        playbackQueue.skipToPrevious()
        replaceCurrentTrack()
    }

    func jumpToTrack(at index: Int) {
        guard index != playbackQueue.currentIndex else { return }
        playbackQueue.jumpToTrack(at: index)
        replaceCurrentTrack()
    }

    func beginScrubbing() {
        isScrubbing = true
    }

    func endScrubbing() {
        isScrubbing = false
        let target = progress * (duration ?? 0)
        currentTime = target
        let cmTime = CMTime(seconds: target, preferredTimescale: 600)
        player.seek(to: cmTime)
    }

    func handleItemDidFinish() {
        if playbackQueue.canAdvance {
            next()
        } else {
            isPlaying = false
            progress = 0
            currentTime = 0
            player.seek(to: .zero)
        }
    }

    private func replaceCurrentTrack() {
        loadGeneration += 1
        let generation = loadGeneration

        currentTime = 0
        progress = 0
        duration = nil
        playbackError = nil

        if let token = endObserverToken {
            NotificationCenter.default.removeObserver(token)
            endObserverToken = nil
        }

        guard let url = playbackQueue.currentTrack?.previewURL else {
            player.replaceCurrentItem(with: nil)
            playbackError = String(localized: "Preview unavailable")
            isPlaying = false
            return
        }

        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)

        endObserverToken = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: item,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleItemDidFinish()
            }
        }

        Task { [weak self] in
            do {
                let cmTime = try await item.asset.load(.duration)
                let seconds = cmTime.seconds
                guard seconds.isFinite, seconds > 0 else { return }
                await MainActor.run {
                    guard let self, self.loadGeneration == generation else { return }
                    self.duration = seconds
                }
            } catch {
                await MainActor.run {
                    guard let self, self.loadGeneration == generation else { return }
                    self.playbackError = error.localizedDescription
                    self.isPlaying = false
                }
            }
        }

        if isPlaying {
            configureAudioSessionIfNeeded()
            player.play()
        }
    }

    private func setUpTimeObserver() {
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self, !self.isScrubbing else { return }
                let seconds = time.seconds
                self.currentTime = seconds.isFinite ? seconds : 0
                if let total = self.duration, total > 0 {
                    self.progress = max(0, min(1, self.currentTime / total))
                } else {
                    self.progress = 0
                }
            }
        }
    }

    private func configureAudioSessionIfNeeded() {
        guard !didConfigureAudioSession else { return }
        didConfigureAudioSession = true
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        try? session.setActive(true, options: [])
        #endif
    }
}
