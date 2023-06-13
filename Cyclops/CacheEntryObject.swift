//
//  CacheEntryObject.swift
//  Cyclops
//
//  Created by José Duarte on 13/06/2023.
//

import Foundation

final class CacheEntryObject<T> where T: Sendable {
    let entry: CacheEntry<T>
    init(entry: CacheEntry<T>) {
        self.entry = entry
    }
}

enum CacheEntry<T> where T: Sendable {
    case inProgress(Task<T, Error>)
    case ready(T)
}
