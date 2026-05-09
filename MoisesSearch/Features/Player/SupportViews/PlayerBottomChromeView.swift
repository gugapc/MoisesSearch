//
//  PlayerBottomChromeView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 05/05/26.
//

import SwiftUI

/// Fixed bottom stack: track info, progress, times, transport (Figma-aligned chrome).
struct PlayerBottomChromeView: View {
    let trackTitle: String
    let artistName: String
    @Binding var progress: Double
    @Binding var isPlaying: Bool
    @Binding var isRepeatEnabled: Bool
    let durationSeconds: Double
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onScrubbingChanged: (Bool) -> Void
    let hasPrevious: Bool
    let hasNext: Bool
    var playbackErrorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text(trackTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let playbackErrorMessage {
                    Text(playbackErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .accessibilityIdentifier("player_playback_error")
                }

                HStack(alignment: .center, spacing: 12) {
                    Text(artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Button {
                        isRepeatEnabled.toggle()
                    } label: {
                        Image(systemName: "repeat")
                            .font(.body.weight(.medium))
                            .foregroundStyle(isRepeatEnabled ? Color.accentColor : .secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Repeat"))
                    .accessibilityValue(Text(isRepeatEnabled ? String(localized: "On") : String(localized: "Off")))
                    .accessibilityIdentifier("player_repeat_toggle")
                }
            }
            .padding(.bottom, 14)

            Slider(value: $progress, in: 0...1, onEditingChanged: onScrubbingChanged)
                .tint(Color.accentColor)

            HStack {
                Text(PlayerBottomChromeView.formatTime(elapsedSeconds))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text("-\(PlayerBottomChromeView.formatTime(remainingSeconds))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)

            PlayerControlsView(
                isPlaying: $isPlaying,
                onPrevious: onPrevious,
                onNext: onNext,
                hasPrevious: hasPrevious,
                hasNext: hasNext,
                playEnabled: playbackErrorMessage == nil
            )
            .padding(.top, 12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var elapsedSeconds: Int {
        Int((progress * durationSeconds).rounded(.down))
    }

    private var remainingSeconds: Int {
        max(0, Int(durationSeconds) - elapsedSeconds)
    }

    private static func formatTime(_ totalSeconds: Int) -> String {
        let s = max(0, totalSeconds)
        let m = s / 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }
}


private struct PlayerControlsView: View {
    @Binding var isPlaying: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let hasPrevious: Bool
    let hasNext: Bool
    let playEnabled: Bool

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            backwardButton

            playButton

            forwardButton

            Spacer()
        }
    }

    private var backwardButton: some View {
        Button(action: onPrevious) {
            Image(systemName: "backward.end.alt.fill")
                .font(.title2)
                .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .disabled(!hasPrevious)
    }

    private var playButton: some View {
        Button {
            isPlaying.toggle()
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 25)
                .scaledToFit()
                .padding()
        }
        .buttonStyle(.glass)
        .disabled(!playEnabled)
        .accessibilityLabel(String(localized: isPlaying ? "Pause" : "Play"))
    }

    private var forwardButton: some View {
        Button(action: onNext) {
            Image(systemName: "forward.end.alt.fill")
                .font(.title2)
                .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .disabled(!hasNext)
    }
}
