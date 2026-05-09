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
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    private var iconSpacing: CGFloat {
        isRegularWidth ? 24 : 16
    }

    private var songInfoSpacing: CGFloat {
        isRegularWidth ? 6 : 4
    }
    
    private var iconSize: CGFloat {
        isRegularWidth ? 78 : 52
    }

    private var iconCornerRadius: CGFloat {
        isRegularWidth ? 12 : 8
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Button(action: onTapRow) {
                HStack(alignment: .center, spacing: iconSpacing) {
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
        .padding(.vertical, 8)
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
        .frame(width: iconSize, height: iconSize)
        .clipShape(RoundedRectangle(cornerRadius: iconCornerRadius, style: .continuous))
    }

    private func artworkPlaceholder(showProgress: Bool) -> some View {
        Rectangle()
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
        VStack(alignment: .leading, spacing: songInfoSpacing) {
            Text(item.title)
                .font(isRegularWidth ? .title3.weight(.semibold) : .body.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
            Text(item.artist)
                .font(isRegularWidth ? .body : .subheadline)
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
