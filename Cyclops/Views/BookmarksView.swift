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
        NavigationStack {
            List {
                ForEach(bookmarks) { bookmark in
                    ItemView(
                        id: Int(bookmark.id),
                        url: bookmark.url!,
                        title: bookmark.title!,
                        time: Int(bookmark.time)
                    )
                }
                // I wanted the slide to show a trash icon but this is the only way I could make it work
                // The .slideActions seems to delete the item, reload the view but not update the request
                // so when it takes out the bookmark again, it's been deleted and the unwrap fails
                // The explanation may be incorrect but for now, it's the best I know of
                .onDelete(perform: deleteBookmark)
            }
            .navigationBarTitle(Text("Bookmarks"), displayMode: .inline)
            .listStyle(.plain)
        }
    }

    func deleteBookmark(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(bookmarks[index])
        }
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
