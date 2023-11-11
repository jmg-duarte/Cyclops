//
//  OnboardingView.swift
//  Cyclops
//
//  Created by José Duarte on 09/11/2023.
//

import SwiftUI

struct AnimationValues {
    var angle: Double = 0
}

struct OnboardingView: View {
    @AppStorage(UserDefaults.Keys.WasOnboarded) private var wasOnboarded = UserDefaults.Defaults.WasOnboarded
    
    @Environment(\.appDatabase) private var appDatabase
    
    @State private var selectedPage: Int = 0
    @State private var introOpacity: Double = 0
    @State private var itemDetail: Item?
    
    private var item = Item.sampleData[0]
    
    var introView: some View {
        VStack(alignment: .center) {
            VStack {
                // TODO: replace with an image with less bordering
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 100)
                    .keyframeAnimator(initialValue: AnimationValues()) { content, value in
                        content
                            .rotationEffect(.degrees(value.angle))
                            
                    } keyframes: { _ in
                        KeyframeTrack(\.angle) {
                            CubicKeyframe(135, duration: 1.5)
                            CubicKeyframe(135, duration: 1.2)
                            CubicKeyframe(60, duration: 1.3)
                            CubicKeyframe(60, duration: 1.0)
                            CubicKeyframe(-20, duration: 1.0)
                            CubicKeyframe(-20, duration: 1.0)
                            CubicKeyframe(0, duration: 0.5)
                            CubicKeyframe(0, duration: 1.0)
                        }
                    }
                Text("Welcome to").font(.title3)
                Text("Cyclops").font(.title).bold()
                
            }.frame(maxHeight: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
            Button {
                selectedPage = 1
            } label: {
                Text("Next \(Image(systemName: "arrow.right"))")
            }
        }.opacity(introOpacity)
            .onAppear {
                withAnimation(Animation.easeIn(duration: 1.0)) {
                    introOpacity = 1
                }
            }
    }
    
    var basicView: some View {
        VStack(alignment: .center) {
            VStack(spacing: 20) {
                ItemView(item: item)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 20)
                Text("Click the item to open it in the browser")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            }.frame(maxHeight: .infinity)
            Button {
                selectedPage = 2
            } label: {
                Text("Next \(Image(systemName: "arrow.right"))")
            }
        }
    }
    
    var longPressView: some View {
        VStack(alignment: .center) {
            VStack(spacing: 20) {
                ItemView(item: Item.sampleData[0])
                    .foregroundStyle(.primary)
                    .contextMenu {
                        Button {
                            Task { try! await appDatabase.saveBookmark(item) }
                        } label: {
                            Label("Bookmark", systemImage: "bookmark")
                        }
                        ShareLink(item: item.url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button {
                            self.itemDetail = item
                        } label: {
                            Label("Details", systemImage: "ellipsis.circle")
                        }
                    }
                    .sheet(item: $itemDetail) { item in
                        // https://stackoverflow.com/a/63217450
                        ItemDetailsSheet(item: item)
                            .presentationDetents([.fraction(0.4)])
                    }
                    .padding(.horizontal, 20)
                Text("Long press for more actions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            }.frame(maxHeight: .infinity)
            Button {
                selectedPage = 3
            } label: {
                Text("Next \(Image(systemName: "arrow.right"))")
            }
        }
    }
    
    var swipeView: some View {
        VStack(alignment: .center) {
            VStack {
                List {
                    ForEach(Item.sampleData) { item in
                        ItemView(item: item)
                            .swipeActions(edge: .leading) {
                                Button {
                                    Task { try! await appDatabase.saveBookmark(item) }
                                } label: {
                                    Label("Bookmark", systemImage: "bookmark.fill")
                                }
                                .tint(.blue)
                            }
                    }
                }.listStyle(.plain)
                    // So janky, but it works!
                    .frame(maxHeight: 250)
                Text("You can bookmark items by swiping right\n(and delete them in the Bookmarks tab by swiping left)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity)
            Button {
                wasOnboarded = true
            } label: {
                Text("Start using Cyclops")
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedPage) {
            introView.tag(0)
            basicView.tag(1)
            longPressView.tag(2)
            swipeView.tag(3)
        }
        .padding(.vertical, 20)
        .transition(.slide)
    }
}

#Preview {
    OnboardingView()
}
