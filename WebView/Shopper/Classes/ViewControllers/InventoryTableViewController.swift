//
//  InventoryTableViewController.swift
//  Shopper
//
//  Created by Gene Backlin on 9/16/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit
import CoreData

protocol InventoryTableViewControllerDelegate {
    func itemWillSave(item: [String : AnyObject])
}

class InventoryTableViewController: UITableViewController {
    var isShopping = false
    var selectedItems: [String : Inventory] = [String : Inventory]()
    var delegate: ShoppingBasketViewControllerDelegate?
    
    var currentInventoryCount: Int {
        get {
            return fetchedInventoryResultsController.sections![0].numberOfObjects
        }
    }
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
        let aFetchedInventoryResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.shared.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Inventory")
        aFetchedInventoryResultsController.delegate = self
        _fetchedInventoryResultsController = aFetchedInventoryResultsController
        
        do {
            try _fetchedInventoryResultsController!.performFetch()
        } catch {
            displayCoreDataError(error: error)
        }
        
        return _fetchedInventoryResultsController!
    }
    var _fetchedInventoryResultsController: NSFetchedResultsController<Inventory>? = nil

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isShopping == false {
            navigationItem.leftBarButtonItem = editButtonItem
        }
    }

    // MARK: - @IBAction methods
    
    @IBAction func addNewInventoryItem(_ sender: UIBarButtonItem) {
        if isShopping == false {
            let tabBarCount = (tabBarController?.viewControllers!.count)! - 1
            tabBarController?.selectedIndex = tabBarCount
            let navController: UINavigationController = tabBarController?.viewControllers?[tabBarCount] as! UINavigationController
            let controller: InventoryEntryViewController = navController.viewControllers[0] as! InventoryEntryViewController
            controller.delegate = self
        } else {
            delegate?.didSelectItems(items: selectedItems)
        }
    }

    // MARK: - Utility methods
    
    func deleteInventoryItem(at indexPath: IndexPath) {
        let context = fetchedInventoryResultsController.managedObjectContext
        context.delete(fetchedInventoryResultsController.object(at: indexPath))
        do {
            try context.save()
        } catch {
            displayCoreDataError(error: error)
        }
    }

    func displayCoreDataError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            let nserror = error as NSError
            let alertController = UIAlertController(title: nil, message: "Unresolved error \(nserror), \(nserror.userInfo)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self!.present(alertController, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - UITableView methods

extension InventoryTableViewController {
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedInventoryResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedInventoryResultsController.sections![section].numberOfObjects
        if isShopping == false {
            if count < 1 {
                navigationItem.leftBarButtonItem!.isEnabled = false
            } else {
                navigationItem.leftBarButtonItem!.isEnabled = true
            }
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = fetchedInventoryResultsController.object(at: indexPath)
        
        configureCell(cell, withInventoryItem: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteInventoryItem(at: indexPath)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let item: Inventory = fetchedInventoryResultsController.object(at: indexPath)

        if isShopping == true {
            if cell?.accessoryType == .checkmark {
                cell?.accessoryType = .none
                selectedItems.removeValue(forKey: item.productCode!)
            } else {
                cell?.accessoryType = .checkmark
                selectedItems[item.productCode!] = item
            }
        }
    }
    
    // MARK: - UITableViewCell display
    
    func configureCell(_ cell: UITableViewCell, withInventoryItem item: Inventory) {
        cell.textLabel!.text = item.itemDescription!.description
        cell.detailTextLabel?.text = item.price.description
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension InventoryTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withInventoryItem: anObject as! Inventory)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withInventoryItem: anObject as! Inventory)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - InventoryTableViewControllerDelegate

extension InventoryTableViewController: InventoryTableViewControllerDelegate {
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
            displayCoreDataError(error: error)
        }
    }
}
