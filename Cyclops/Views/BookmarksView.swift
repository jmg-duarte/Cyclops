//
//  BookmarkView.swift
//  Cyclops
//
//  Created by José Duarte on 18/06/2023.
//

import CoreData
import SwiftUI

struct BookmarksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // I should probably add an "added" field to the bookmarks for sorting for now, fuck it
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)]) var bookmarks: FetchedResults<Bookmark>
    var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                ItemView(
                    id: Int(bookmark.id),
                    url: bookmark.url!,
                    title: bookmark.title!,
                    time: Int(bookmark.time)
                )
            }
            .onDelete(perform: deleteBookmark)
        }
        .listStyle(.plain)
    }

    func deleteBookmark(at offsets: IndexSet) {
        for index in offsets {
            let language = bookmarks[index]
            viewContext.delete(language)
        }
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
