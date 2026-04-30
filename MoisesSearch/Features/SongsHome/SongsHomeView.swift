//
//  SongsHomeView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 30/04/26.
//

import SwiftUI

struct SongsHomeView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            CollapsingHeaderView(
                searchText: $searchText,
                navigationTitle: String(localized: "Songs")
            ) {
                ForEach(0 ..< 30, id: \.self) { index in
                    Text("Post \(index)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }
}

#Preview("Songs home") {
    SongsHomeView()
}
