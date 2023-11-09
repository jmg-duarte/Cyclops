// ItemView.swift
// Created by José Duarte on 09/06/2023
// Copyright (c) 2023

import SwiftUI
import Combine
import GRDB
import GRDBQuery

struct ItemView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.appDatabase) private var appDatabase
    @AppStorage(UserDefaults.Keys.ShowNumberOfComments) private var showNumberOfComments = UserDefaults.Defaults.ShowNumberOfComments

    let id: Int
    let url: URL
    let title: String
    let time: UnixEpoch
    let numberOfComments: Int
    
    // Not great but ¯\_(ツ)_/¯
    // https://developer.apple.com/forums/thread/120497?answerId=384664022#384664022
    private var viewedPublisher: AnyPublisher<Bool, Never> {
        ValueObservation.tracking { db in
            let viewed = (try? Viewed.filter(Column("id") == id).fetchOne(db)) ?? nil
            return viewed != nil
        }
        .publisher(in: appDatabase.reader, scheduling: .immediate)
        // SAFETY: default nil is set in case it fails
        // it's just whether a link was viewed, it's not the end
        // of the world if it is wrong/fails
        .assertNoFailure()
        .eraseToAnyPublisher()
    }
    @State private var viewed: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Link(destination: url) {
                    Text(title).font(.headline).multilineTextAlignment(.leading)
                }
                 .environment(\.openURL, OpenURLAction { _ in
                     Task {try! await appDatabase.saveViewed(Viewed(id))}
                     return .systemAction
                 })
                HStack {
                    Text("\(time.formattedTimeAgo) (\(url.host()!))").font(.caption)
                    if showNumberOfComments {
                        Text("\(Image(systemName: "bubble.left.and.text.bubble.right.fill")) \(numberOfComments)").font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            if viewed {
                 Spacer()
                 Image(systemName: "eye")
             }
        }
        .onReceive(viewedPublisher) {
            viewed = $0
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
            time: Item.sampleData[0].time!,
            numberOfComments: Item.sampleData[0].descendants ?? 0
        )
    }
}
