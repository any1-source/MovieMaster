//
//  SQLiteTempScreen.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 18.05.24.
//

import SwiftUI

struct SQLiteTempScreen: View {
    @Environment(SQLiteViewModel.self) private var sqliteViewModel
    @Binding var currentUserID: Int
    @State private var counter: Int64 = 1
    var body: some View {
        VStack(spacing:0) {
            Divider()
            Text("SQLiteTest").font(.title2).frame(maxWidth: .infinity).background(.orange.opacity(0.8))
            Divider()
            HStack(spacing: 0) {
                addButtonMovie
                resetButton
            }
            NavigationView {
                List {
                    ForEach(sqliteViewModel.seenMovies, id: \.id){ movie in
                            Text("\(movie.id)")
                                .bold()
                                .draggable(movie)
                                .dropDestination(for: myMovie.self) { movies, location in
                                    sqliteViewModel.swapOrder(swap: movie.id, with: movies[0].id, user: Int64(currentUserID))
                                    sqliteViewModel.fetchSeenMovies(user: Int64(currentUserID))
                                    return true
                                } isTargeted: { _ in
                                    
                                }
                    }.onDelete { index in
                        sqliteViewModel.changeIsMoviefromList(movieIds: index, isFromWatchList: false, user: Int64(currentUserID))
                        sqliteViewModel.fetchSeenMovies(user: Int64(currentUserID) )
                    }
                }
                .navigationTitle("Seen Movies")
                .scrollContentBackground(.hidden)// Add this
                .background(Color.mint.opacity(0.6))
                .onAppear {
                    //TODO: remove this after testing or something bad happens
                    currentUserID = sqliteViewModel.getUserId(ofName: "root")
                    sqliteViewModel.fetchSeenMovies(user: Int64(currentUserID))
                    
                }
            }
            Divider()
            HStack(spacing: 0) {
                addButtonUser
            }
            NavigationView {
                List {
                    ForEach(sqliteViewModel.users, id: \.id){ user in
                        HStack {
                            Text("\(user.id) - name: \(user.name) - password: \(user.password)").bold()
                        }
                    }.onDelete { index in
                        sqliteViewModel.deleteUser(at: index)
                        sqliteViewModel.fetchUsers()
                    }
                }
                .navigationTitle("Users")
            }
        }
    }
    private var addButtonMovie: some View {
        Button(action: { sqliteViewModel.addMovieUsersList(movie:counter ,user:Int64(currentUserID),isWatchList: true,isSeenMovie: true);
            sqliteViewModel.fetchSeenMovies(user: Int64(currentUserID));
            counter = counter + 1;
        }) {
            Image(systemName: "plus").imageScale( Image.Scale.medium)
        }
    }
    private var addButtonUser: some View {
        Button(action: { sqliteViewModel.addToUsers(name: "root\(counter)", password: "-\(counter)-");
            sqliteViewModel.fetchUsers();
            counter = counter + 1;
        }) {
            Image(systemName: "plus").imageScale( Image.Scale.large)
        }
    }
    private var resetButton: some View {
        Button(action: { sqliteViewModel.clearMovieUserTable(user: Int64(currentUserID)); sqliteViewModel.fetchSeenMovies(user: Int64(currentUserID)) }) {
            Image(systemName: "clear").imageScale(Image.Scale.medium)
        }
    }
}
//#Preview {
    //    @State var temp:Int = 1
    //SQLiteTempScreen(currentUserID: $temp).environment(SQLiteViewModel())
//}

