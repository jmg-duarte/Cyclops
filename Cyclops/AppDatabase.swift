//
//  AppDatabase.swift
//  Cyclops
//
//  Created by José Duarte on 30/10/2023.
//

import Foundation
import GRDB
import OSLog

// Stolen't from GRDB's demo
// See the following link for more information:
// https://github.com/groue/GRDB.swift/blob/master/Documentation/DemoApps/GRDBAsyncDemo/GRDBAsyncDemo/AppDatabase.swift
struct AppDatabase {
    
    private let dbWriter: any DatabaseWriter
    
    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
}

// MARK: - Database Configuration

extension AppDatabase {
    private static let sqlLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")
    
    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        var config = base
        
        if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
            config.prepareDatabase { db in
                db.trace {
                    sqlLogger.debug("\($0)")
                }
            }
        }
        #if DEBUG
        config.publicStatementArguments = true
        #endif
        
        return config
    }
}

// MARK: - Migrations

extension AppDatabase {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        // I'm a lazy SOB so instead of figuring out how to store "item" as "bookmark" I decided to assume that every stored item is a bookmark
        // Which makes sense but when it comes to names, it is different
        migrator.registerMigration("createBookmark") { db in
            try db.create(table: "item") { table in
                table.primaryKey(["id"])
                table.column("id", .integer)
                table.column("type", .text).notNull()
                table.column("url", .text).notNull()
                table.column("by", .text)
                table.column("dead", .boolean)
                table.column("deleted", .boolean)
                table.column("descendants", .integer)
                table.column("parent", .integer)
                table.column("poll", .integer)
                table.column("score", .integer)
                table.column("text", .text)
                table.column("time", .integer)
                table.column("title", .text)
                table.column("kids", .jsonText)
                table.column("parts", .jsonText)
            }
        }
        
        migrator.registerMigration("createViewed") { db in
            try db.create(table: "viewed") { table in
                table.primaryKey(["id"])
                table.column("id", .integer)
            }
        }
        
        return migrator
    }
}

// MARK: - Database writes

extension AppDatabase {
    func saveBookmark(_ bookmark: Item) async throws {
        // The brackets capture the bookmark value at the time of the closure declaration
        // creating a copy and ensuring the data doesn't change inside the closure
        _ = try await dbWriter.write { [bookmark] db in
            try bookmark.saved(db)
        }
    }
    
    func deleteBookmark(_ id: Int) async throws {
        try await dbWriter.write { db in
            _ = try Item.deleteOne(db, id: id)
        }
    }
    
    // TODO: this will need to be inout when viewed keeps track of how many times a single link was viewed or the last time it was clicked
    func saveViewed(_ viewed: Viewed) async throws {
        _ = try await dbWriter.write { [viewed] db in
            try viewed.saved(db)
        }
    }
    
    func deleteAllViewed() async throws {
        try await dbWriter.write { db in
            _ = try Viewed.deleteAll(db)
        }
    }
}

// MARK: - Database read-only access

extension AppDatabase {
    var reader: DatabaseReader {
        dbWriter
    }
}
