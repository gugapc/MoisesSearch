//
//  EmptySearchPlaceholderView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import SwiftUI

struct EmptySearchPlaceholderView: View {
    let searchText: String
    private var isSearchEmpty: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isSearchEmpty ? "music.pages" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text(String(localized: isSearchEmpty ? "No searches yet" : "No results"))
                .font(.headline)
            if !isSearchEmpty {
                Text(String(localized: "Try another search."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 32)
    }
}

#Preview("Empty search") {
    EmptySearchPlaceholderView(searchText: "")
    Divider()
    EmptySearchPlaceholderView(searchText: "Muse")
}
