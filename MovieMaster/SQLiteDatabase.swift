//
//  DB.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 18.05.24.
//
import SwiftUI
import Foundation
import SQLite
import UniformTypeIdentifiers

struct User: Identifiable, Hashable{
    var id: Int64
    var name: String
    var password: String
}
struct myMovie: Codable, Identifiable, Hashable, Transferable{
    var id: Int64
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .myMovie)
    }
}
extension UTType {
    static let myMovie = UTType(exportedAs: "test.myMovie")
}
@Observable
class SQLiteViewModel{
    var movies: [myMovie] = []
    var seenMovies: [myMovie] = []
    var watchList: [myMovie] = []
    var users: [User] = []
    private let db: Connection?
    
    private let movieTable = Table("Movies")
    private let usersTable = Table("Users")
    private let moviesUsersTable = Table("MoviesUsersRelation")
    private let orderTable = Table("Order")
    private let isWatchList = Expression<Bool>("isWatchList")
    private let isSeenMovie = Expression<Bool>("isSeenMovie")
    private let id = Expression<Int64>("id")
    private let userId = Expression<Int64>("userId")
    private let movieId = Expression<Int64>("movieId")
    private let order = Expression<Int64>("order")
    private let name = Expression<String>("name")
    private let password = Expression<String>("password")
    
    init(){
        //create Database file if not already exists
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil,create: true)
            let fileUrl = documentDirectory.appendingPathComponent("movies").appendingPathExtension("sqlite3")
            db = try Connection("\(fileUrl.path)")
            createTables()
            //TODO: remove later
            addTestData()
            print("movies Database conn ok")
        } catch {
            db = nil
            print("Unable to create and/or open database. Error: \(error)")
        }
    }
    private func createTables(){
        do {
            //CREATE TABLE seenMovies IF NOT EXISTS {id int primary Key}
            try db?.run(movieTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
            })
            
            try db?.run(moviesUsersTable.create(ifNotExists: true) { t in
                t.column(order, primaryKey: .autoincrement)
                t.column(movieId)
                t.column(userId)
                t.column(isSeenMovie, defaultValue: false)
                t.column(isWatchList, defaultValue: false)
                t.foreignKey(userId, references: usersTable, id)
                t.foreignKey(movieId, references: movieTable, id)
                t.unique(userId, movieId)
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
    func addToMovie(id movieId: Int64){
        let insert = movieTable.insert( self.id <- movieId)
        do {
            try db?.run(insert)
            print("Inserted seen movie")
        } catch {
            print("Insert seen movie failed: \(error)")
        }
    }
    func addMovieUsersList(movie movieId: Int64, user userId: Int64, isWatchList: Bool, isSeenMovie: Bool){
        let insert = moviesUsersTable.insert( self.movieId <- movieId, self.userId <- userId, self.isWatchList <- isWatchList, self.isSeenMovie <- isSeenMovie)
        do {
            addToMovie(id: movieId)
            try db?.run(insert)
            print("Inserted to be watched movie")
        } catch {
            print("addMovieUsersList failed: \(error)")
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
    func clearMovies()
    {
        do {
            try db?.run(movieTable.delete())
        } catch {
            print("Failed to clear table seenMovies: \(error)")
        }
    }
    func clearMovieUserTable(user userId: Int64?)
    {
        do {
            if let userId = userId{
                try db?.run(moviesUsersTable.filter(self.userId==userId).delete())
            }else{
                try db?.run(moviesUsersTable.delete())
            }
        } catch {
            print("Failed to clear table seenMovies: \(error)")
        }
    }
    func deleteMovie(at offsets: IndexSet){
        do {
             try offsets.forEach{ id in
                 let movie = movieTable.filter(self.movieId == movies[id].id)
                try db?.run(movie.delete())
            }
            
        } catch {
            print("Delete seen movie from table failed: \(error)")
        }
    }
    
    func changeIsMoviefromList(movieIds offsets: IndexSet,isFromWatchList fromWatchList: Bool?, user userId: Int64){
        do {
             try offsets.forEach{ id in
                 let userMovieRelation = moviesUsersTable.filter(self.movieId == seenMovies[id].id && self.userId == userId)
                 if let movie = try db?.pluck(userMovieRelation) {
                        if let fromWatchList = fromWatchList {
                            if fromWatchList {
                                try db?.run(userMovieRelation.update(self.isWatchList <- !movie[self.isWatchList]))
                            } else {
                                try db?.run(userMovieRelation.update(self.isSeenMovie <- !movie[self.isSeenMovie]))
                            }
                        } else {
                            try db?.run(userMovieRelation.update(self.isWatchList <- !movie[self.isWatchList], self.isSeenMovie <- !movie[self.isSeenMovie]))
                        }
                 }
            }
            
        } catch {
            print("changeIsMoviefromList failed: \(error)")
        }
    }
    
    func deleteUser(at offsets: IndexSet){
        do {
            try offsets.forEach{ id in
                let user = usersTable.filter(self.id == users[id].id)
                try db?.run(user.delete())
            }
        } catch {
            print("Delete user from table failed: \(error)")
        }
    }
    func fetchSeenMovies(user userId: Int64) {
        var resultItems = [myMovie]()
        
        do {
            for item in try db!.prepare(moviesUsersTable.filter(self.userId == userId && isSeenMovie == true).order(order.asc)) {
                    resultItems.append(myMovie(id:item[movieId]))
            }
        } catch {
            print("Fetch cat failed: \(error)")
        }

        seenMovies = resultItems
    }
    func fetchWatchListMovies(user userId: Int64) {
        var resultItems = [myMovie]()
        
        do {
            for item in try db!.prepare(moviesUsersTable.filter(self.userId == userId && isWatchList == true)) {
                    resultItems.append(myMovie(id:item[movieId]))
            }
        } catch {
            print("Fetch cat failed: \(error)")
        }

        watchList = resultItems
    }
    func fetchUsers(){
        var resultItems = [User]()
        
        do {
            for item in try db!.prepare(usersTable) {
                resultItems.append(User(id:item[id], name:item[name], password:item[password]))
            }
        } catch {
            print("Fetch cat failed: \(error)")
        }

        users = resultItems
    }
    private func fetchMovies(){
        var resultItems = [myMovie]()
        do {
            for item in try db!.prepare(movieTable) {
                resultItems.append(myMovie(id:item[id]))
            }
        } catch {
            print("Fetch cat failed: \(error)")
        }

        movies = resultItems
    }
    private func addTestData() {
        do {
                try db?.run(movieTable.delete())
                try db?.run(moviesUsersTable.delete())
                try db?.run(usersTable.delete())
                addToMovie(id: 1)
                addToMovie(id: 2)
                addToMovie(id: 3)
            
                addToUsers(name: "root", password: "123")
                let userId = Int64(getUserId(ofName:"root"))
            addMovieUsersList(movie: 1, user: userId,isWatchList:  true,isSeenMovie: true)
                addMovieUsersList(movie: 2, user: userId,isWatchList:  true,isSeenMovie: true)
                addMovieUsersList(movie: 3, user: userId,isWatchList:  true,isSeenMovie: true)
                swapOrder(swap: getOrder(ofMovie: 1, ofUser: userId), with: getOrder(ofMovie: 3, ofUser: userId), user: userId)
            } catch {
                print("failed to init data for seen Movies: \(error)")
                
            }
    }
    func getUserId(ofName name: String) -> Int {
        do {
            if let user = try db?.pluck(usersTable.filter(self.name == name)) {
                return Int(user[self.id])
            }
        } catch{
            print("some error occured in getuserId(ofName: ...): \(error)")
        }
        return -1
    }
    private func getOrder(ofMovie movieId: Int64, ofUser userId: Int64) -> Int64{
        do {
            if let movie = try db?.pluck(moviesUsersTable.filter(self.movieId == movieId && self.userId == userId)) {
                return movie[self.order]
            }
        } catch{
            print("some error occured in getOrder(ofName: ...): \(error)")
        }
        return -1
    }
    func swapOrder(swap first: Int64, with second: Int64, user userId: Int64) {
        do {
            let firstdMovie = moviesUsersTable.filter(self.userId == userId && self.order == first)
            let secondMovie = moviesUsersTable.filter(self.userId == userId && self.order == second)
            if let firstMovie = try db?.pluck(firstdMovie), let secondMovie = try db?.pluck(secondMovie){
                let firstId = firstMovie[self.order]
                let secondId = secondMovie[self.order]
                //get the id that is most likely not used in the database
                var unusedId: Int64 = -1
                if let movie = try db?.pluck(moviesUsersTable.order(self.order.asc).limit(1)) {
                    unusedId = movie[self.order]-1
                }
                
                //swap Ids or Order
                try db?.run(moviesUsersTable.filter(self.order == firstId).update(self.order <- unusedId))
                try db?.run(moviesUsersTable.filter(self.order == secondId).update(self.order <- firstId))
                try db?.run(moviesUsersTable.filter(self.order == unusedId).update(self.order <- secondId))
            }
        } catch{
            print("\(error)")
        }
    }
}
