//
//  InventoryController.swift
//  ShopperTests
//
//  Created by Gene Backlin on 9/17/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit
import CoreData

class InventoryController: NSObject {
    private var context: NSManagedObjectContext?

    var fetchedInventoryResultsController: NSFetchedResultsController<Inventory> {
        if _fetchedInventoryResultsController != nil {
            return _fetchedInventoryResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Inventory> = Inventory.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "productCode", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedInventoryResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.contextForTests(), sectionNameKeyPath: nil, cacheName: "Inventory")
        aFetchedInventoryResultsController.delegate = self
        _fetchedInventoryResultsController = aFetchedInventoryResultsController
        
        do {
            try _fetchedInventoryResultsController!.performFetch()
        } catch {
            debugPrint(error.localizedDescription)
        }
        
        return _fetchedInventoryResultsController!
    }
    var _fetchedInventoryResultsController: NSFetchedResultsController<Inventory>? = nil

    var inventoryCount: Int {
        get {
            return fetchedInventoryResultsController.sections![0].numberOfObjects
        }
    }

    func addInventoryItem(productCode: String, itemDescription: String, price: Double, tax: Double, isImported: Bool) {
        var inventoryItem: [String : AnyObject] = [String : AnyObject]()
        
        inventoryItem[PRODUCT_CODE] = productCode as AnyObject
        inventoryItem[ITEM_DESCRIPTION] = itemDescription as AnyObject
        inventoryItem[PRICE] = price as AnyObject
        inventoryItem[TAX] = tax as AnyObject
        inventoryItem[IMPORTED] = isImported as AnyObject

        itemWillSave(item: inventoryItem)
        }
    
    func fetchAllObjects() -> [Inventory]? {
        return fetchedInventoryResultsController.fetchedObjects
    }
    func delete(item: Inventory) {
        let context = fetchedInventoryResultsController.managedObjectContext
        context.delete(item)
    }
    
    func itemWillSave(item: [String : AnyObject]) {
        let context = fetchedInventoryResultsController.managedObjectContext
        let newItem = Inventory(context: context)
        
        // If appropriate, configure the new managed object.
        newItem.productCode = item[PRODUCT_CODE] as? String
        newItem.itemDescription = item[ITEM_DESCRIPTION] as? String
        newItem.price = (item[PRICE] as? Double)!
        newItem.tax = (item[TAX] as? Double)!
        newItem.imported = (item[IMPORTED] as? Bool)!
        
        // Save the context.
        do {
            try context.save()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

}
// MARK: - NSFetchedResultsControllerDelegate

extension InventoryController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        debugPrint("controllerWillChangeContent")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        default:
            debugPrint("didChange sectionInfo")
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        default:
            debugPrint("didChange anObject")
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        debugPrint("controllerDidChangeContent")
    }
}

