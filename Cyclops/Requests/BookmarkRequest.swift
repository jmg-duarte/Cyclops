//
//  File.swift
//  Cyclops
//
//  Created by José Duarte on 31/10/2023.
//

import Combine
import GRDB
import GRDBQuery

struct BookmarkRequest: Queryable {
    static var defaultValue: [Item] {[]}
    
    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<[Item], Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.reader,
                       scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws -> [Item] {
        return try Item.all().orderedByTime().fetchAll(db)
    }
}
