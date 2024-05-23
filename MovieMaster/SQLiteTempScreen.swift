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
            HStack(spacing: 0) {
                addButton
                resetButton
            }
            NavigationView {
                List {
                    ForEach(sqliteViewModel.seenMovies, id: \.order){ movie in
                        HStack {
                            Text("\(movie.order) – \(movie.id)").bold()
                        }
                    }.onDelete { index in
                        sqliteViewModel.deleteSeenMovie(at: index)
                        sqliteViewModel.fetchSeenMovies()
                    }
                }
                .navigationTitle("Seen Movies")
                .scrollContentBackground(.hidden)// Add this
                .background(Color.mint.opacity(0.6))
                .onAppear {
                    sqliteViewModel.fetchSeenMovies()
                }
            }
        }
    }
    private var addButton: some View {
        Button(action: { sqliteViewModel.addToSeenMovie(id:1);sqliteViewModel.fetchSeenMovies() }) {
            Image(systemName: "plus").imageScale( Image.Scale.medium)
        }
    }
    private var resetButton: some View {
        Button(action: { sqliteViewModel.clearSeenMovies(); sqliteViewModel.fetchSeenMovies() }) {
            Image(systemName: "clear").imageScale(Image.Scale.medium)
        }
    }
}
#Preview {
    SQLiteTempScreen().environment(SQLiteViewModel())
}

