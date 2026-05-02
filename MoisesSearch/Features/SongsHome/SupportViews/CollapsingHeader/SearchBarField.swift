//
//  SearchBarField.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 29/04/26.
//

import SwiftUI

struct SearchBarField: View {
    @Binding var text: String
    var placeholder: String = String(localized: "Search")
    var opacity: CGFloat = 1

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $text)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel(String(localized: "Search songs"))
                .accessibilityHint(String(localized: "Type to search the iTunes catalog"))

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(String(localized: "Clear search"))
                .accessibilityIdentifier("clear_search_button")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 46)
        .background(Color.primary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .opacity(opacity)
    }
}

#Preview {
    SearchBarFieldPreviewHost()
}

private struct SearchBarFieldPreviewHost: View {
    @State private var query = "draft"

    var body: some View {
        SearchBarField(text: $query)
            .padding()
            .background(Color.black)
            .preferredColorScheme(.dark)
    }
}
