//
//  PersistentStore.swift
//  IoTWeather
//
//  Created by steven freed on 8/20/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import Foundation
import CoreData

// Core Data Stack
class PersistentStore {
    
     private init() {}
    
    // MARK: - Persistent Container
    static var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "WeatherUpdates")
        
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

    // MARK: - Save Core Data context
    static func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
    
    // MARK: - Delete from Core Data
    static func deleteContext() {
        let context = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WReading")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Save a weather reading
    static func saveReading(temp: Int16, view: String) {
        
        let context = PersistentStore.persistentContainer.viewContext
        PersistentStore.deleteContext()
        // Save data to Core Data
        let wReading = WReading(context: context)
        wReading.temp = temp
        wReading.view = view
        
        do {
            try context.save()
        } catch {
            print(error)
        }
        
    }
    
    // MARK: - Request the latest weather reading
    static func requestReading() -> WReading? {
        
        let fetchReq: NSFetchRequest<WReading> = WReading.fetchRequest()
        
        do {
            let update = try PersistentStore.persistentContainer.viewContext.fetch(fetchReq)
            if update.count != 0
            {
            return update[0]
            }
            
        } catch {
            print(error)
        }
        
        return nil
    }

}
