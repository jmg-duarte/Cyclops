//
//  ViewedRequest.swift
//  Cyclops
//
//  Created by José Duarte on 31/10/2023.
//

import Combine
import GRDB
import GRDBQuery

struct ViewedStoryCount: Queryable {
    static var defaultValue: Int { 0 }
    
    func publisher(in appDatabase: AppDatabase) -> AnyPublisher<Int, Error> {
        ValueObservation
            .tracking(fetchValue(_:))
            .publisher(in: appDatabase.reader,
                       scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func fetchValue(_ db: Database) throws ->  Int {
        return try SQLRequest<Int>("SELECT COUNT(*) FROM viewed").fetchOne(db) ?? 0
    }
}
