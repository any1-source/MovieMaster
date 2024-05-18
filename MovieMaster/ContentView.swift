//
//  ContentView.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 09.05.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView() {
            MovieScreen().tabItem{
                Label("SQL", systemImage: "1.circle")}
            SQLiteTempScreen().tabItem{
                Label("SQL",
                      systemImage:
                "2.circle")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
