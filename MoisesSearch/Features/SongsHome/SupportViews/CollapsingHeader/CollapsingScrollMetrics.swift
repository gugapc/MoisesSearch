//
//  CollapsingScrollMetrics.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 29/04/26.
//

import SwiftUI

struct ScrollDistanceTracker: View {
    @Binding var scrollDistance: CGFloat
    @State private var baselineMinY: CGFloat?

    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            Color.clear
                .onAppear {
                    if baselineMinY == nil {
                        baselineMinY = minY
                    }
                    updateDistance(currentMinY: minY)
                }
                .onChange(of: minY) { _, newValue in
                    if baselineMinY == nil {
                        baselineMinY = newValue
                    }
                    updateDistance(currentMinY: newValue)
                }
        }
        .frame(height: 1)
        .accessibilityHidden(true)
    }

    private func updateDistance(currentMinY: CGFloat) {
        guard let baseline = baselineMinY else { return }
        // Scrolling down the list moves content up → global minY decreases.
        scrollDistance = max(0, baseline - currentMinY)
    }
}
