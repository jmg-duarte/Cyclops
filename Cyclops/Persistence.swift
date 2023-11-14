//
//  Persistence.swift
//  Cyclops
//
//  Created by José Duarte on 31/10/2023.
//

import Foundation
import GRDB

extension AppDatabase {
    static let shared = makeShared()
    
    private static func makeShared() -> AppDatabase {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
            
            if CommandLine.arguments.contains("-reset") {
                try? fileManager.removeItem(at: directoryURL)
            }
            
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            NSLog("Database stored at \(databaseURL.path)")
            let dbPool = try DatabasePool(path: databaseURL.path, configuration: AppDatabase.makeConfiguration())
            
            let appDatabase = try AppDatabase(dbPool)
            if CommandLine.arguments.contains("-fixedTestData") {
                // needs dummy data
            } else {
                // makes the db empty (?)
            }
            
            return appDatabase
        } catch {
            fatalError("Unresolved error \(error)")
        }
    }
    
    static func empty() -> AppDatabase {
        let dbQueue = try! DatabaseQueue(configuration: AppDatabase.makeConfiguration())
        return try! AppDatabase(dbQueue)
    }
    
    static func demo() -> AppDatabase {
        let appDatabase = empty()
        try! appDatabase.createSampleBookmarks()
        return appDatabase
    }
}
