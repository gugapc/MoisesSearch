//
//  SongRowView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI

struct SongRowView: View {
    let item: SongListItem
    var showsMoreButton: Bool = true
    var onTapRow: () -> Void
    var onMore: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onTapRow) {
                HStack(alignment: .center, spacing: 12) {
                    songIcon

                    songInfo
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if showsMoreButton {
                moreButton
            }
        }
        .padding(.vertical, 6)
    }
    
    private var songIcon: some View {
        Group {
            if let url = item.artworkURL {
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
    
    private var songInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            Text(item.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var moreButton: some View {
        Menu {
            Button(String(localized: "View album")) {
                onMore?()
            }
            .accessibilityIdentifier("song_row_view_album_\(item.id)")
        } label: {
            Image(systemName: "ellipsis")
                .tint(.secondary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .disabled(item.collectionId == nil)
        .accessibilityLabel(String(localized: "More options"))
        .accessibilityIdentifier("song_row_more_\(item.id)")
    }
}

#Preview {
    List {
        SongRowView(item: SongListItem(id: "1", title: "Purple Rain", artist: "Prince"), onTapRow: {}, onMore: {})
        SongRowView(item: SongListItem(id: "2", title: "Get Lucky", artist: "Daft Punk"), onTapRow: {}, onMore: {})
    }
}
