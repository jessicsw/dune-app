//
//  DuniverseWidget.swift
//  DuniverseWidget
//
//  Created by Jessica Wong on 3/21/24.
//

import WidgetKit
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

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        fetchRandomQuote { quote in
            let entry = SimpleEntry(date: Date(), quote: quote)
            completion(entry)
        }
       
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        fetchRandomQuote { quote in
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, quote: quote)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }

    }
    
    func fetchRandomQuote(completion: @escaping (Quote?) -> Void) {
        Task {
            do {
                let url = URL(string: "https://api.duniverse.space/v1/random")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let quote = try JSONDecoder().decode(Quote.self, from: data)
                completion(quote)
            } catch {
                print("Error fetching random quote: \(error)")
                completion(nil)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: Quote?
}

struct DuniverseWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let quote = entry.quote {
            VStack(alignment: .leading, spacing: 10) {
                Text(quote.text)
                    .font(.headline)
                Text("Book: \(quote.book.title)")
                Text("Author: \(quote.book.author.name)")
            }
            .padding()
        }
    }
}

func fetchRandomQuote() async throws -> Quote {
    let url = URL(string: "https://api.duniverse.space/v1/random")!
    let (data,_) = try await URLSession.shared.data(from: url)
    let quote = try JSONDecoder().decode(Quote.self, from: data)
    return quote
}

struct DuniverseWidget: Widget {
    let kind: String = "DuniverseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DuniverseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Duniverse Widget")
        .description("This is a Duniverse Widget. It will show you Dune wisdom.")
    }
}

struct DuniverseWidget_Previews: PreviewProvider {
    
    static var previews: some View {
        let quote = Quote(
            id: "c59f2bd5-bcff-44cc-8cae-2b064bd7c641",
            text: "Beyond a critical point within a finite space, freedom diminishes as numbers increase.",
            book: Book(
                 title: "Dune",
                 author: Author(
                      name: "Frank Herbert"
                 )
            )
       )

        DuniverseWidgetEntryView(entry: SimpleEntry(date: Date(), quote: quote))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
