//
//  ContentView.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 09.05.24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentUserID: Int = -1 // TODO: lock up how to use Int64 or change Database type accordingly
    @State private var selectedTab: Int = 0 // screen no 0
    
    var body: some View {
        TabView() {
            MovieScreen(currentUserID: $currentUserID).tabItem{
                Label("MDB", systemImage: "1.circle")}.tag(0)
            SQLiteTempScreen(currentUserID: $currentUserID).tabItem{
                Label("SQL",
                      systemImage:
                "2.circle").tag(1)
            }.onAppear { 
                selectedTab = loadSelectedTab()
                currentUserID = loadLastLoggedUser()
            }.onChange(of: selectedTab) { oldState, newState in saveSelectedTab(newState) }
            .onChange(of: currentUserID) { oldState, newState in saveLastLoggedUser(newState)
            }
        }
        .padding()
    }
    private static let loggedUser = "lastLoggedUser"
    private static let selectedTabKey = "lastSelectedTab"
    
    //save and load variables that need to be read before every start
    
    private func loadLastLoggedUser() -> Int {
        return UserDefaults.standard.integer(forKey: ContentView.loggedUser)
    }
    
    private func saveLastLoggedUser(_ newState: Int)//TODO:maybe Int64 is needed
    {
        UserDefaults.standard.set(newState, forKey: ContentView.loggedUser)
    }
    
    private func loadSelectedTab() -> Int {
        return UserDefaults.standard.integer(forKey: ContentView.selectedTabKey)
    }
    
    private func saveSelectedTab(_ newState: Int) {
        UserDefaults.standard.set(newState, forKey: ContentView.selectedTabKey)
    }
}

#Preview {
    ContentView()
}
