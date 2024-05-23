//
//  MovieDatabase.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 09.05.24.
//
import SwiftUI
import Foundation

struct MovieViewModelKey: EnvironmentKey {
    static let defaultValue: any MovieViewModelProtocol = MovieViewModelMock()
}

extension EnvironmentValues {
    var movieViewModel: any MovieViewModelProtocol {
        get { self[MovieViewModelKey.self] }
        set { self[MovieViewModelKey.self] = newValue }
    }
}

protocol MovieViewModelProtocol: Observable {
    var movies: [Movie] { get set }
    
    func fetch()
}
@Observable
class MovieViewModelMock: MovieViewModelProtocol {
    static let movie_collection: [Movie] = [
        Movie(adult:true, backdropPath:"123", genreIDS:[1, 2, 3], id:1, originalLanguage: "de", originalTitle: "Der Untergang", overview:"Film über Nazi-Deutschland", popularity: 10.0, posterPath:"/", releaseDate:"2002-01-01", title:"Downfall", video:true,voteAverage:10000, voteCount:1),
        Movie(adult:true, backdropPath:"345", genreIDS:[2, 4, 6], id:1, originalLanguage: "en", originalTitle: "Mission Impossible", overview:"Spy Film", popularity: 5.0, posterPath:"/123", releaseDate:"2002-08-08", title:"Mission Impossible", video:true, voteAverage:3000, voteCount:10000)
    ]
    
    var movies: [Movie] = MovieViewModelMock.movie_collection
    var isLoading = false
    
    func fetch() { }
}
struct MoviePage: Codable {
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable, Hashable {
    let adult: Bool
    let backdropPath: String?
    let genreIDS: [Int]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

@Observable
class MovieViewModel : MovieViewModelProtocol {
    var isLoading = false
    var movies : [Movie] = []
    func fetch() {
        //data is loading currently
        isLoading = true
        //url
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc") else {return}
        //create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //Add headers
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue( "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyYmIzNzlhNzBmNzA1NjJhMzM3M2IyNDZmZmUzODU0OCIsInN1YiI6IjY2M2NkMmI5YWM3M2FkOGU2MDg5MzZkZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.-XXAxPaG5v5bZ23FASUXz4cjDqBruNSubq3p_cciDkI", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = true
                guard let data = data, error == nil else {
                    print(error ?? "couldnt be loaded")
                    return
                }
                print("data could be recived")
                do {
                    let movies = try JSONDecoder().decode(MoviePage.self, from: data)
                    DispatchQueue.main.async {
                        self?.movies = movies.results
                    }
                    return
                }catch{
                    print(error)
                }
                // handle error
                print("Failed to load: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
        
    }
}
