//
//  DB.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 18.05.24.
//
import SwiftUI
import Foundation
import SQLite

struct User: Identifiable, Hashable{
    var id: Int64
    var name: String
    var password: String
}
struct myMovie: Identifiable, Hashable{
    var id: Int64
}
@Observable
class SQLiteViewModel{
    var seenMovies: [myMovie] = []
    var watchList: [myMovie] = []
    var users: [User] = []
    private let db: Connection?
    
    private let seenMovieTable = Table("seenMovies")
    private let watchListTable = Table("watchList")
    private let usersTable = Table("users")
    
    private let id = Expression<Int64>("id")
    private let movieId = Expression<Int64>("movieId")
    private let order = Expression<Int64>("order")
    private let name = Expression<String>("name")
    private let password = Expression<String>("password")
    
    init(){
        //create Database file if not already exists
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil,create: true)
            let fileUrl = documentDirectory.appendingPathComponent("movies").appendingPathExtension("sqlite3")
            db = try Connection("\(fileUrl.path)/movies.sqlite3")
            createTables()
            print("movies Database conn ok")
        } catch {
            db = nil
            print("Unable to create and/or open database. Error: \(error)")
        }
    }
    private func createTables(){
        do {
            //CREATE TABLE seenMovies IF NOT EXISTS {id int primary Key}
            try db?.run(seenMovieTable.create(ifNotExists: true) { t in
                t.column(order, primaryKey: .autoincrement)
                t.column(movieId, unique: true)
            })
            
            try db?.run(watchListTable.create(ifNotExists: true) { t in
                t.column(order, primaryKey: .autoincrement)
                t.column(movieId, unique: true)
            })
            
            try db?.run(usersTable.create(ifNotExists: true) {
                t in t.column(id, primaryKey: .autoincrement)
                t.column(name, unique: true)
                t.column(password)
            })
        } catch {
            print("Failed to create table: \(error)")
        }
    }
    func addToSeenMovie(id movieId: Int64){
        let insert = seenMovieTable.insert( self.movieId <- movieId)
        do {
            try db?.run(insert)
            print("Inserted seen movie")
        } catch {
            print("Insert seen movie failed: \(error)")
        }
    }
    func addToWatchList(id movieId: Int64){
        let insert = watchListTable.insert( self.movieId <- movieId)
        do {
            try db?.run(insert)
            print("Inserted to be watched movie")
        } catch {
            print("Insert to be watched movie failed: \(error)")
        }
    }
    func addToUsers(name: String, password: String){
        let insert = usersTable.insert(self.name <- name, self.password <- password)
        do {
            try db?.run(insert)
            print("Inserted user")
        } catch {
            print("Insert user failed: \(error)")
        }
    }
    func clearSeenMovies()
    {
        do {
            try db?.run(seenMovieTable.delete())
        } catch {
            print("Failed to clear table seenMovies: \(error)")
        }
    }
    func clearWatchList()
    {
        do {
            try db?.run(watchListTable.delete())
        } catch {
            print("Failed to clear table seenMovies: \(error)")
        }
    }
    func deleteSeenMovie(id movieId: Int64){
        do {
            let seenMovie = seenMovieTable.filter(self.movieId == movieId)
            try db?.run(seenMovie.delete())
        } catch {
            print("Delete seen movie from table failed: \(error)")
        }
    }
    func deleteWatchListMovie(id movieId: Int64){
        do {
            let watchListMovie = watchListTable.filter(self.movieId == movieId)
            try db?.run(watchListMovie.delete())
        } catch {
            print("Delete to be watched movie from table failed: \(error)")
        }
    }
    func deleteUser(id: Int64){
        do {
            let user = usersTable.filter(self.id == id)
            try db?.run(user.delete())
        } catch {
            print("Delete user from table failed: \(error)")
        }
    }
    func fetchSeenMovies() {
        var resultItems = [myMovie]()
        
        do {
            for item in try db!.prepare(seenMovieTable) {
                resultItems.append(myMovie(id:item[movieId]))
            }
        } catch {
            print("Fetch cat failed: \(error)")
        }

        seenMovies = resultItems
    }
    func fetchWatchListMovies() {
        var resultItems = [myMovie]()
        
        do {
            for item in try db!.prepare(watchListTable) {
                resultItems.append(myMovie(id:item[movieId]))
            }
        } catch {
            print("Fetch cat failed: \(error)")
        }

        watchList = resultItems
    }
    func fetchUsers() -> [User] {
        var resultItems = [User]()
        
        do {
            for item in try db!.prepare(usersTable) {
                resultItems.append(User(id:item[id], name:item[name], password:item[password]))
            }
        } catch {
            print("Fetch cat failed: \(error)")
        }

        users = resultItems
        return resultItems;
    }
}
