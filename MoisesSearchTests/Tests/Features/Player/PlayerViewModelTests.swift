//
//  PlayerViewModelTests.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 05/05/26.
//

import Foundation
import Testing
@testable import MoisesSearch

@Suite(.tags(.unit))
@MainActor
struct PlayerViewModelTests {
    @Test func togglePlayPause_flipsIsPlaying() {
        let sut = makeViewModel()
        #expect(sut.isPlaying == false)

        sut.togglePlayPause()
        #expect(sut.isPlaying == true)

        sut.togglePlayPause()
        #expect(sut.isPlaying == false)
    }

    @Test func next_advancesQueue_andResetsProgress() {
        let queue = makeQueue(count: 3, startAt: 0)
        let sut = makeViewModel(queue: queue)
        sut.progress = 0.4

        sut.next()

        #expect(queue.currentIndex == 1)
        #expect(sut.progress == 0)
    }

    @Test func previous_rewindsQueue_andResetsProgress() {
        let queue = makeQueue(count: 3, startAt: 2)
        let sut = makeViewModel(queue: queue)
        sut.progress = 0.7

        sut.previous()

        #expect(queue.currentIndex == 1)
        #expect(sut.progress == 0)
    }

    @Test func jumpToTrack_setsIndex_andResetsProgress() {
        let queue = makeQueue(count: 4, startAt: 0)
        let sut = makeViewModel(queue: queue)
        sut.progress = 0.3

        sut.jumpToTrack(at: 3)

        #expect(queue.currentIndex == 3)
        #expect(sut.progress == 0)
    }

    @Test func beginScrubbing_endScrubbing_toggleFlag() {
        let sut = makeViewModel()
        #expect(sut.isScrubbing == false)

        sut.beginScrubbing()
        #expect(sut.isScrubbing == true)

        sut.endScrubbing()
        #expect(sut.isScrubbing == false)
    }

    @Test func proxies_forwardToQueue() {
        let queue = makeQueue(count: 3, startAt: 1)
        let sut = makeViewModel(queue: queue)

        #expect(sut.canAdvance == queue.canAdvance)
        #expect(sut.canRewind == queue.canRewind)
        #expect(sut.currentTrack == queue.currentTrack)
        #expect(sut.currentTrack?.id == "1")
    }

    @Test func endOfTrack_advancesQueue_whenCanAdvance() {
        let queue = makeQueue(count: 3, startAt: 0)
        let sut = makeViewModel(queue: queue)
        sut.progress = 0.99

        sut.handleItemDidFinish()

        #expect(queue.currentIndex == 1)
        #expect(sut.progress == 0)
    }

    @Test func endOfTrack_stopsAtLastTrack() {
        let queue = makeQueue(count: 3, startAt: 2)
        let sut = makeViewModel(queue: queue)
        sut.isPlaying = true
        sut.progress = 0.99

        sut.handleItemDidFinish()

        #expect(queue.currentIndex == 2)
        #expect(sut.isPlaying == false)
        #expect(sut.progress == 0)
    }

    @Test func previewUnavailable_setsPlaybackError() {
        let queue = PlaybackQueue()
        queue.replace(
            with: [SongListItem(id: "1", title: "No preview", artist: "X")],
            startAt: 0
        )

        let sut = PlayerViewModel(playbackQueue: queue)

        #expect(sut.playbackError != nil)
    }

    private func makeQueue(count: Int, startAt: Int = 0) -> PlaybackQueue {
        let queue = PlaybackQueue()
        let tracks = (0..<count).map { SongListItem(id: "\($0)", title: "T\($0)", artist: "A\($0)") }
        queue.replace(with: tracks, startAt: startAt)
        return queue
    }

    private func makeViewModel(queue: PlaybackQueue? = nil) -> PlayerViewModel {
        PlayerViewModel(playbackQueue: queue ?? makeQueue(count: 1))
    }
}
