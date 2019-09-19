//
//  CoreDataService.swift
//  Shopping
//
//  Created by Gene Backlin on 9/14/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import CoreData

let PRODUCT_CODE = "productCode"
let ITEM_DESCRIPTION = "itemDescription"
let PRICE = "price"
let TAX = "tax"
let IMPORTED = "imported"

class CoreDataService: NSObject {
    static let shared = CoreDataService()
    
    var containerName: String?
    var managedObjectContext: NSManagedObjectContext? = nil
    
    // MARK: - Core Data stack
    
    private override init() {
        super.init()
        containerName = "Shopper"
        managedObjectContext = persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: containerName!)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext(completion: ((NSError?) -> Void)? = nil) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion!(nil)
            } catch {
                let nserror = error as NSError
                completion!(nserror)
                //fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension NSManagedObjectContext {

    class func contextForTests() -> NSManagedObjectContext {
        // Get the model
        let model = NSManagedObjectModel.mergedModel(from: Bundle.allBundles)!

        // Create and configure the coordinator
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try! coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

        // Setup the context
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }

}
