// ItemView.swift
// Created by José Duarte on 09/06/2023
// Copyright (c) 2023

import CoreData
import SwiftUI

struct ItemView: View {
    let id: Int
    let url: URL
    let title: String
    let time: UnixEpoch
    
    /*
     https://stackoverflow.com/questions/72150965/how-can-i-observe-an-array-of-coredata-objects-in-swiftui
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [],
        predicate: ) var bookmarks: FetchedResults<Bookmark>

    @State private var hasBeenRead: Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReadLink")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        ((try? viewContext.count(for: fetchRequest)) ?? 0) > 0
    }
    
    init(id: Int, url: URL, title: String, time: UnixEpoch) {
        self.id = id
        self.url = url
        self.title = title
        self.time = time
        
    }
    
    func markAsRead() {
        let readLink = ReadLink(context: viewContext)
        readLink.id = Int64(id)
        try? viewContext.save()
        hasBeenRead = true
    }
     */
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Link(destination: url) {
                    Text(title).font(.headline).multilineTextAlignment(.leading)
                }
                /*
                .environment(\.openURL, OpenURLAction { _ in
                    markAsRead()
                    return .systemAction
                })
                 */
                HStack {
                    Text(time.formattedTimeAgo).font(.caption)
                    Text("(\(url.host()!))").font(.caption)
                }
            }
            /*
            if hasBeenRead {
                Spacer()
                Image(systemName: "eye")
            }
             */
        }
        // Without this, the HStack will trigger all the "tappable" actions
        // See the following link for more information:
        // - https://stackoverflow.com/a/59402642
        // Right now I need the whole HStack to be tappable but I'm leaving this
        // for whenever I want to add new buttons
        // .buttonStyle(.plain)
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(
            id: Item.sampleData[0].id,
            url: Item.sampleData[0].url,
            title: Item.sampleData[0].title!,
            time: Item.sampleData[0].time!
        )
    }
}
