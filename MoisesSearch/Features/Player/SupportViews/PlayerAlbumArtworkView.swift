//
//  PlayerAlbumArtworkView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 05/05/26.
//

import SwiftUI

struct PlayerAlbumArtworkView: View {
    let artworkURL: URL?
    var maxSide: CGFloat

    var body: some View {
        Group {
            if let url = artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                            .overlay { ProgressView() }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: maxSide, height: maxSide)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.primary.opacity(0.08))
            .overlay {
                Image(systemName: "music.note")
                    .font(.system(size: max(48, maxSide * 0.18)))
                    .foregroundStyle(.tertiary)
            }
    }
}
