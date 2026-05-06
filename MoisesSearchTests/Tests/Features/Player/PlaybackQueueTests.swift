//
//  PlaybackQueueTests.swift
//  MoisesSearchTests
//

import Foundation
import Testing
@testable import MoisesSearch

@MainActor
struct PlaybackQueueTests {
    @Test func replace_withEmptyItems_resetsIndexToZero_andCurrentTrackToNil() {
        let queue = PlaybackQueue()
        queue.replace(with: makeTracks(count: 3), startAt: 2)

        queue.replace(with: [], startAt: 5)

        #expect(queue.tracks.isEmpty)
        #expect(queue.currentIndex == 0)
        #expect(queue.currentTrack == nil)
    }

    @Test func replace_clampsStartAt_toValidRange() {
        let queue = PlaybackQueue()
        let tracks = makeTracks(count: 3)

        queue.replace(with: tracks, startAt: 99)
        #expect(queue.currentIndex == 2)

        queue.replace(with: tracks, startAt: -4)
        #expect(queue.currentIndex == 0)
    }

    @Test func advanceToNext_isNoOp_whenEmpty() {
        let queue = PlaybackQueue()

        queue.advanceToNext()

        #expect(queue.currentIndex == 0)
        #expect(queue.currentTrack == nil)
    }

    @Test func advanceToNext_increments_andStopsAtLastIndex() {
        let queue = PlaybackQueue()
        queue.replace(with: makeTracks(count: 3), startAt: 0)

        queue.advanceToNext()
        #expect(queue.currentIndex == 1)

        queue.advanceToNext()
        #expect(queue.currentIndex == 2)
        #expect(queue.currentTrack?.id == "2")

        queue.advanceToNext()
        #expect(queue.currentIndex == 2)
    }

    @Test func skipToPrevious_isNoOp_whenEmpty() {
        let queue = PlaybackQueue()

        queue.skipToPrevious()

        #expect(queue.currentIndex == 0)
        #expect(queue.currentTrack == nil)
    }

    @Test func skipToPrevious_decrements_andStopsAtFirstIndex() {
        let queue = PlaybackQueue()
        queue.replace(with: makeTracks(count: 3), startAt: 2)

        queue.skipToPrevious()
        #expect(queue.currentIndex == 1)

        queue.skipToPrevious()
        #expect(queue.currentIndex == 0)
        #expect(queue.currentTrack?.id == "0")

        queue.skipToPrevious()
        #expect(queue.currentIndex == 0)
    }

    @Test func jumpToTrack_setsIndex_forValidIndex() {
        let queue = PlaybackQueue()
        queue.replace(with: makeTracks(count: 4), startAt: 0)

        queue.jumpToTrack(at: 3)

        #expect(queue.currentIndex == 3)
        #expect(queue.currentTrack?.id == "3")
    }

    @Test func jumpToTrack_isNoOp_forOutOfRange() {
        let queue = PlaybackQueue()
        queue.replace(with: makeTracks(count: 3), startAt: 1)

        queue.jumpToTrack(at: 99)
        #expect(queue.currentIndex == 1)

        queue.jumpToTrack(at: -1)
        #expect(queue.currentIndex == 1)
    }

    @Test func canAdvance_reflectsRemainingTracks() {
        let queue = PlaybackQueue()
        #expect(queue.canAdvance == false)

        queue.replace(with: makeTracks(count: 1), startAt: 0)
        #expect(queue.canAdvance == false)

        queue.replace(with: makeTracks(count: 3), startAt: 0)
        #expect(queue.canAdvance == true)

        queue.advanceToNext()
        #expect(queue.canAdvance == true)

        queue.advanceToNext()
        #expect(queue.canAdvance == false)
    }

    @Test func canRewind_reflectsPriorTracks() {
        let queue = PlaybackQueue()
        #expect(queue.canRewind == false)

        queue.replace(with: makeTracks(count: 1), startAt: 0)
        #expect(queue.canRewind == false)

        queue.replace(with: makeTracks(count: 3), startAt: 0)
        #expect(queue.canRewind == false)

        queue.advanceToNext()
        #expect(queue.canRewind == true)

        queue.advanceToNext()
        #expect(queue.canRewind == true)
    }

    private func makeTracks(count: Int) -> [SongListItem] {
        (0..<count).map { SongListItem(id: "\($0)", title: "T\($0)", artist: "A\($0)") }
    }
}
