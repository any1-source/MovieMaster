//
//  MovieMasterApp.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 09.05.24.
//

import SwiftUI

@main
struct MovieMasterApp: App {
    @State private var movieViewModel = MovieViewModel()
    @State private var sqliteViewModel = SQLiteViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.movieViewModel, movieViewModel)
                .environment(
                sqliteViewModel)
        }
    }
}
