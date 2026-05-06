//
//  PlayerQueueSidebarView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 05/05/26.
//

import SwiftUI

struct PlayerQueueSidebarView: View {
    let tracks: [SongListItem]
    let currentIndex: Int
    var onSelectTrack: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(localized: "Play queue"))
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                        queueRow(index: index, track: track)
                    }
                }
            }
        }
        .frame(minWidth: 280, idealWidth: 300, maxWidth: 340)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private func queueRow(index: Int, track: SongListItem) -> some View {
        let isCurrent = index == currentIndex
        return Button {
            onSelectTrack(index)
        } label: {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.subheadline.weight(isCurrent ? .semibold : .regular))
                        .foregroundStyle(isCurrent ? Color.accentColor : Color.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(track.artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                if isCurrent {
                    Image(systemName: "waveform")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .accessibilityLabel(String(localized: "Now playing"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if isCurrent {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentColor.opacity(0.12))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }
}
