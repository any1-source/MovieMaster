//
//  MovieScreen.swift
//  MovieMaster
//
//  Created by Lennard Helbig on 10.05.24.
//
import SwiftUI
import Foundation

struct MovieScreen: View {
    @Environment(\.movieViewModel) var movieViewModel
    var body: some View {
        VStack(spacing:3) {
            Divider()
            Text("MoviesTest").font(.title2).frame(maxWidth: .infinity).background(.orange.opacity(0.8))
            Divider()
            NavigationView {
                List {
                    ForEach(movieViewModel.movies, id: \.self) {
                        movie in
                        HStack{
                            Image("").frame(width:130, height:70)
                                .background(Color.gray)
                            
                            Text(movie.originalTitle)
                                .bold()
                        }
                        
                    }
                }.navigationTitle("Movies")
                .onAppear{
                    movieViewModel.fetch()}
            }
        }
    }
}
#Preview {
    MovieScreen().environment(MovieViewModelMock())
}
