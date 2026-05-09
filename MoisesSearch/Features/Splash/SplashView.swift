//
//  SplashView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 08/05/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    private var startPoint: UnitPoint {
        isRegularWidth ? .topLeading : .topTrailing
    }

    private var endPoint: UnitPoint {
        isRegularWidth ? .bottomTrailing : .bottomLeading
    }
    
    private var iconSize: CGFloat {
        isRegularWidth ? 256 : 100
    }

    let onFinish: () -> Void

    private let visibleDuration: Duration = .milliseconds(1_500)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.0 / 255.0, green: 134.0 / 255.0, blue: 160.0 / 255.0), .black],
                startPoint: startPoint,
                endPoint: endPoint
            )
            .ignoresSafeArea()

            Image("MusicalNote")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .accessibilityIdentifier("splash_logo")
                .accessibilityLabel(String(localized: "Moises"))
        }
        .task {
            try? await Task.sleep(for: visibleDuration)
            guard !Task.isCancelled else { return }
            onFinish()
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
