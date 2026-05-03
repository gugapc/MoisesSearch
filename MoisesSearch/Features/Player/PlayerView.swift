//
//  PlayerView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import SwiftUI

struct PlayerView: View {
    @Bindable var playbackQueue: PlaybackQueue

    var body: some View {
        VStack(spacing: 20) {
            playerArtwork
            if let track = playbackQueue.currentTrack {
                Text(track.title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    @ViewBuilder
    private var playerArtwork: some View {
        if let url = playbackQueue.currentTrack?.artworkURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 240, height: 240)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    genericArtworkSymbol
                @unknown default:
                    genericArtworkSymbol
                }
            }
            .frame(width: 240, height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            genericArtworkSymbol
        }
    }

    private var genericArtworkSymbol: some View {
        Image(systemName: "music.note.list")
            .font(.system(size: 80))
            .foregroundStyle(.tertiary)
            .frame(width: 240, height: 240)
    }
}
