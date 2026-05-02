//
//  MoisesSearchApp.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import SwiftUI

@main
struct MoisesSearchApp: App {
    @State private var homeViewModel = SongsHomeViewModel()

    var body: some Scene {
        WindowGroup {
            SongsHomeView(viewModel: homeViewModel)
        }
    }
}
