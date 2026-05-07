//
//  SnapshotEnvironment.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import SwiftUI

extension View {
    /// Applies the dynamic type / color scheme / layout direction environment used across
    /// snapshot tests, plus the matching dark/light backdrop so screenshots are not transparent.
    func snapshotEnvironment(
        dynamicTypeSize: DynamicTypeSize = .medium,
        colorScheme: ColorScheme,
        layoutDirection: LayoutDirection = .leftToRight,
        width: CGFloat? = nil
    ) -> some View {
        let background = colorScheme == .dark ? Color.black : Color.white
        return self
            .environment(\.dynamicTypeSize, dynamicTypeSize)
            .environment(\.colorScheme, colorScheme)
            .environment(\.layoutDirection, layoutDirection)
            .background(background)
            .frame(width: width)
    }
}
