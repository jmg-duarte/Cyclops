//
//  DataController.swift
//  Cyclops
//
//  Created by José Duarte on 18/06/2023.
//

import CoreData
import Foundation
import os

class PersistenceController: ObservableObject {
    
    static let containerName = "Model"
    
    static var preview: PersistenceController {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        for item in Item.sampleData {
            let bookmark = Bookmark(context:context)
            bookmark.id = Int64(item.id)
            bookmark.title = item.title
            bookmark.url = item.url
            bookmark.time = Int64(item.time!) 
        }
        try? context.save()
        return controller
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PersistenceController.self)
    )
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: PersistenceController.self.containerName)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        #if targetEnvironment(simulator)
        let path = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask).debugDescription
            .replacingOccurrences(of: "%20", with: " ")
        PersistenceController.logger.debug("\(path)")
        #endif
    }
}


