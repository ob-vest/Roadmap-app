//
//  RoadmapApp.swift
//  Roadmap
//
//  Created by Onur Bas on 27/02/2024.
//

import SwiftUI

@main
struct RoadmapApp: App {
    @State var authVM = AuthViewModel()
//    @State var sessionVM = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RoadmapView()
                .environment(authVM)
                .environment(SessionViewModel.shared)
        }
    }
}
