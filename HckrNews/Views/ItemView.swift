//
//  ItemView.swift
//  HckrNews
//
//  Created by José Duarte on 09/06/2023.
//

import SwiftUI

struct ItemView: View {
    let item: Item

    var body: some View {
        Link(destination: item.url!) {
            VStack(alignment: .leading) {
                Text(item.title!).font(.headline).multilineTextAlignment(.leading)
                HStack {
                    if let timeAgo = item.timeAgoWithUnits {
                        Text(timeAgo)
                    }
                    Text("(\(item.url!.host()!))").font(.caption)
                }
            }
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(item: Item.sampleData[0])
    }
}
