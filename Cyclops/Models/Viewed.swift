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
