//
//  ContentView.swift
//  Duniverse
//
//  Created by Jessica Wong on 3/21/24.
//

import SwiftUI

struct Author: Codable {
    let name: String
}

struct Book: Codable {
    let title: String
    let author: Author
}

struct Quote: Codable {
    let id: String
    let text: String
    let book: Book
}

struct ContentView: View {
    @State private var quote: Quote? = nil
    
    var body: some View {
        VStack {
            if let quote {
                VStack(alignment: .leading, spacing: 10) {
                    Text(quote.text)
                        .font(.title)
                    Text("Book: \(quote.book.title)")
                    Text("Author: \(quote.book.author.name)")
                }
                .padding()
            } else {
                Text("Loading...")
                    .task {
                        do {
                            quote = try await fetchRandomQuote()
                        } catch {
                            quote = nil
                        }
                    }
            }
            Button("Get Random Quote"){
                Task {
                    do {
                        quote = try await fetchRandomQuote()
                    } catch {
                        quote = nil
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.large)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func fetchRandomQuote() async throws -> Quote {
    let url = URL(string: "https://api.duniverse.space/v1/random")!
    let (data,_) = try await URLSession.shared.data(from: url)
    let quote = try JSONDecoder().decode(Quote.self, from: data)
    return quote
}
