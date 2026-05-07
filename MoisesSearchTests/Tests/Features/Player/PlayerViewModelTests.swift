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

    @Test func tick_advancesProgress_whenPlaying() {
        let sut = makeViewModel(placeholderDuration: 4, tickInterval: .seconds(1))
        sut.isPlaying = true

        sut.tick()
        #expect(sut.progress == 0.25)

        sut.tick()
        #expect(sut.progress == 0.5)
    }

    @Test func tick_isNoOp_whenNotPlaying() {
        let sut = makeViewModel(placeholderDuration: 4, tickInterval: .seconds(1))

        sut.tick()

        #expect(sut.progress == 0)
    }

    @Test func tick_clampsProgress_atOne() {
        let sut = makeViewModel(placeholderDuration: 4, tickInterval: .seconds(1))
        sut.isPlaying = true
        sut.progress = 0.9

        sut.tick()
        #expect(sut.progress == 1)

        sut.tick()
        #expect(sut.progress == 1)
    }

    @Test func beginScrubbing_endScrubbing_toggleFlag() {
        let sut = makeViewModel()
        #expect(sut.isScrubbing == false)

        sut.beginScrubbing()
        #expect(sut.isScrubbing == true)

        sut.endScrubbing()
        #expect(sut.isScrubbing == false)
    }

    @Test func tick_isNoOp_whileScrubbing() {
        let sut = makeViewModel(placeholderDuration: 4, tickInterval: .seconds(1))
        sut.isPlaying = true
        sut.beginScrubbing()
        sut.progress = 0.5

        sut.tick()

        #expect(sut.progress == 0.5)
    }

    @Test func proxies_forwardToQueue() {
        let queue = makeQueue(count: 3, startAt: 1)
        let sut = makeViewModel(queue: queue)

        #expect(sut.canAdvance == queue.canAdvance)
        #expect(sut.canRewind == queue.canRewind)
        #expect(sut.currentTrack == queue.currentTrack)
        #expect(sut.currentTrack?.id == "1")
    }

    private func makeQueue(count: Int, startAt: Int = 0) -> PlaybackQueue {
        let queue = PlaybackQueue()
        let tracks = (0..<count).map { SongListItem(id: "\($0)", title: "T\($0)", artist: "A\($0)") }
        queue.replace(with: tracks, startAt: startAt)
        return queue
    }

    private func makeViewModel(
        queue: PlaybackQueue? = nil,
        placeholderDuration: Double = 210,
        tickInterval: Duration = .milliseconds(500)
    ) -> PlayerViewModel {
        PlayerViewModel(
            playbackQueue: queue ?? makeQueue(count: 1),
            placeholderDuration: placeholderDuration,
            tickInterval: tickInterval
        )
    }
}
