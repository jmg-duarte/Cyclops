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
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order:.reverse)]) var bookmarks: FetchedResults<Bookmark>
    var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                ItemView(url: bookmark.url!, title: bookmark.title!, time: Int(bookmark.time))
            }
            // Item onDelete should remove them from the stored data
        }
        .listStyle(.plain)
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
            .environment(\.managedObjectContext, DataController.preview.container.viewContext)
    }
}
