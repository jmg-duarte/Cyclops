//
//  Opened.swift
//  Cyclops
//
//  Created by José Duarte on 30/10/2023.
//

import GRDB

final class Viewed: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: Int
    
    init(_ id: Int) {
        self.id = id
    }
}

// MARK: - Hashable implementation requirements for usage in Set

extension Viewed: Equatable {
    static func == (lhs: Viewed, rhs: Viewed) -> Bool {
        lhs.id == rhs.id
    }
}

extension Viewed: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
