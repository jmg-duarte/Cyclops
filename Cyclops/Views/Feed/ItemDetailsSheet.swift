//
//  ItemDetailsSheet.swift
//  Cyclops
//
//  Created by José Duarte on 25/06/2023.
//

import SwiftUI

class BorderedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        Label(configuration)
            .padding(8)
            .background(Color(UIColor.tertiarySystemFill))
            .cornerRadius(8)
    }
}

extension LabelStyle where Self == BorderedLabelStyle {
    static var send: BorderedLabelStyle { .init() }
}

struct ItemDetailsSheet: View {
    let item: Item

    @State private var isNameShown = false
    @State private var isTimeAgoShown = false

    private var comments: URL {
        return URL(string: "https://news.ycombinator.com/item?id=\(item.id)")!
    }

    private var timeAgo: String {
        if let time = item.time {
            return time.formattedTimeAgo
        } else {
            return ""
        }
    }

    var body: some View {
        List {
            Label("\(item.by!)", systemImage: "person.fill")
                .foregroundColor(.primary)
            
            Label("\(timeAgo)", systemImage: "calendar")
                .foregroundColor(.primary)
            
            Label("\(item.score ?? 0) points", systemImage: "hand.thumbsup.fill")
                .foregroundColor(.primary)
            
            if #available(iOS 17.0, *) {
                Label("\(item.descendants ?? 0) comments", systemImage: "text.bubble.left.and.bubble.right.fill")
                    .foregroundColor(.primary)
            } else {
                Label("\(item.descendants ?? 0) comments", systemImage: "bubble.left.and.bubble.right.fill")
                    .foregroundColor(.primary)
            }
            
            Link(destination: comments) {
                Label("Go to discussion", systemImage: "arrow.turn.up.right")
            }
        }
    }
}

struct ItemDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailsSheet(item: Item.sampleData[0])
    }
}
