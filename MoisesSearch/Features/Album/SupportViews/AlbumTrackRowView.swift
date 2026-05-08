//
//  AlbumTrackRowView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import SwiftUI

/// Album-screen variant of a song row. Distinct from `SongRowView`: no More menu.
struct AlbumTrackRowView: View {
    let track: SongListItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                artwork

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
        .accessibilityIdentifier("album_track_row_\(track.id)")
    }

    private var artwork: some View {
        Group {
            if let url = track.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        artworkPlaceholder(showProgress: true)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        artworkPlaceholder(showProgress: false)
                    @unknown default:
                        artworkPlaceholder(showProgress: false)
                    }
                }
            } else {
                artworkPlaceholder(showProgress: false)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func artworkPlaceholder(showProgress: Bool) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Color.primary.opacity(0.12))
            .overlay {
                if showProgress {
                    ProgressView()
                } else {
                    Image(systemName: "music.note")
                        .foregroundStyle(.secondary)
                }
            }
    }
}

#Preview {
    List {
        AlbumTrackRowView(
            track: SongListItem(id: "2", title: "Around the World", artist: "Daft Punk", collectionId: 1),
            onTap: {}
        )
    }
}
