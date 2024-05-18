//
//  SQLiteTempScreen.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 18.05.24.
//

import SwiftUI

struct SQLiteTempScreen: View {
    @Environment(SQLiteViewModel.self) private var sqliteViewModel
    var body: some View {
        VStack(spacing:0) {
            Divider()
            Text("SQLiteTest").font(.title2).frame(maxWidth: .infinity).background(.orange.opacity(0.8))
            Divider()
            
        }
    }
    private var addButton: some View {
        Button(action: { sqliteViewModel.addToSeenMovie(id:5);sqliteViewModel.fetchSeenMovies() }) {
            Image(systemName: "plus")
        }
    }
    private var resetButton: some View {
        Button(action: { sqliteViewModel.clearSeenMovies(); sqliteViewModel.fetchSeenMovies() }) {
            Image(systemName: "clear")
        }
    }
}
#Preview {
    SQLiteTempScreen().environment(SQLiteViewModel())
}

