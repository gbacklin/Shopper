//
//  ShoppingBasketViewController.swift
//  Shopper
//
//  Created by Gene Backlin on 9/16/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//
// This view controller represents a shopping basket that will display the following:
//      - Items selected from the inventory that are to be purchased
//      - Listed dollar values displaying the subtotal, tax and total dollar value.
//

import UIKit
import CoreData

protocol ShoppingBasketViewControllerDelegate {
    func didSelectItems(items: [String : Inventory])
}

let NO_INVENTORY = "There is no inventory available"
let IMPORT_TAX_RATE = 0.05

class ShoppingBasketViewController: UIViewController {
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var subTotalCostLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var shoppingCart: [String : Inventory] = [String : Inventory]()
    var currentSubTotalValue: Double = 0.0
    var currentTotalValue: Double = 0.0
    var currentTaxTotalValue: Double = 0.0
    var currentInventoryCount: Int {
        get {
            let controller: InventoryTableViewController = storyboard!.instantiateViewController(identifier: "InventoryTableViewController")
            return controller.currentInventoryCount
        }
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateTotalAmount(nil, isDelete: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeDisplay()
    }
        
    // MARK: - @IBAction methods
    
    @IBAction func trash(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Trash", message: "Are you shure you want to empty your basket ?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) {[weak self] (action) in
            self!.shoppingCart.removeAll()
            self!.currentTaxTotalValue = 0.0
            self!.currentTotalValue = 0.0
            self!.currentSubTotalValue = 0.0

            self!.navigationItem.leftBarButtonItem = nil
            self!.trashBarButtonItem.isEnabled = false
            self!.printButton.isEnabled = false
            self!.updateTotalAmount(nil, isDelete: false)
            
            self!.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }

        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Shopping basket total processing
    
    func updateTotalAmount(_ item: Inventory?, isDelete: Bool) {
        var amount = 0.0
        
        if let inventoryItem = item {
            let price = inventoryItem.price
            var tax = inventoryItem.tax
            
            if inventoryItem.imported == true {
                tax += IMPORT_TAX_RATE
            }

            if isDelete == false {
                amount = price + (price * tax)
                currentTaxTotalValue += (price * tax)
                currentSubTotalValue += price
                currentTotalValue += amount
            } else {
                amount = price + (price * tax)
                currentTaxTotalValue -= (price * tax)
                currentSubTotalValue -= price
                currentTotalValue -= amount
            }
        }
        updateTotalsDisplay(subtotal: currentSubTotalValue, amount: currentTotalValue, tax: currentTaxTotalValue)
    }
    
    // MARK: - Display methods
    
    func initializeDisplay() {
        if currentInventoryCount < 1 {
            statusLabel.text = NO_INVENTORY
            addBarButtonItem.isEnabled = false
            trashBarButtonItem.isEnabled = false
            printButton.isEnabled = false
        } else {
            statusLabel.text = ""
            addBarButtonItem.isEnabled = true
            if shoppingCart.count > 0 {
                navigationItem.leftBarButtonItem = editButtonItem
                trashBarButtonItem.isEnabled = true
                printButton.isEnabled = true
            } else {
                navigationItem.leftBarButtonItem = nil
                trashBarButtonItem.isEnabled = false
                printButton.isEnabled = false
            }
            
            currentTaxTotalValue = 0.0
            currentTotalValue = 0.0
            currentSubTotalValue = 0.0

            tableView.reloadData()
        }
    }

    func updateTotalsDisplay(subtotal: Double, amount: Double, tax: Double) {
        if let formattedSubTotal = currencyFormatter.string(from: subtotal as NSNumber) {
            subTotalCostLabel.text = "\(formattedSubTotal)"
            taxLabel.text = ""
        }
        if let formattedTotal = currencyFormatter.string(from: amount as NSNumber) {
            totalCostLabel.text = "\(formattedTotal)"
            taxLabel.text = ""
        }
        if let formattedTaxTotal = currencyFormatter.string(from: tax as NSNumber) {
            taxLabel.text = "\(formattedTaxTotal)"
        }
    }

    // MARK: - Utility
    
    func configureCell(_ cell: UITableViewCell, withInventoryItem item: Inventory) {
        if let formattedPrice: String = currencyFormatter.string(from: NSNumber(value: item.price)) {
            cell.detailTextLabel?.text = formattedPrice
        } else {
            cell.detailTextLabel?.text = "0.00"
        }
        cell.textLabel!.text = item.itemDescription!.description
    }

    func inventoryItem(for indexPath: IndexPath) -> Inventory? {
        var item: Inventory?
        
        if shoppingCart.keys.count > 0 {
            let keys: [String] = Array(shoppingCart.keys)
            let key: String? = keys[indexPath.row]
            if key != nil {
                if let inventoryItem: Inventory = shoppingCart[key!] {
                    item = inventoryItem
                }
            }
        }
        return item
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SelectItems" {
            if let controller: InventoryTableViewController = segue.destination as? InventoryTableViewController {
                controller.isShopping = true
                controller.delegate = self
            }
        } else if segue.identifier == "ShowReceipt" {
            if let controller: ReceiptViewController = segue.destination as? ReceiptViewController {
                let receiptNumber = Date().hashValue
                
                let formattedTax = currencyFormatter.string(from: currentTaxTotalValue as NSNumber)
                let formattedTotal = currencyFormatter.string(from: currentTotalValue as NSNumber)
                let formattedSubTotal = currencyFormatter.string(from: currentSubTotalValue as NSNumber)

                controller.HTMLContent = ReceiptController.shared.renderReceipt(receiptNumber: "\(receiptNumber)", invoiceDate: dateFormatter.string(from: Date()), recipientInfo: nil, items: shoppingCart, subTotalAmount: "\(String(describing: formattedSubTotal!))", taxAmount: "\(String(describing: formattedTax!))", totalAmount: "\(String(describing: formattedTotal!))", shoppingCart: shoppingCart)
                controller.pathToReceiptHTMLTemplate = pathToReceiptHTMLTemplate
                controller.receiptNumber = receiptNumber
            }
        }
    }
    
    var receiptNumber: String?
}

// MARK: - UITableViewDataSource

extension ShoppingBasketViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingCart.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let item = inventoryItem(for: indexPath) {
            configureCell(cell, withInventoryItem: item)
            updateTotalAmount(item, isDelete: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = inventoryItem(for: indexPath) {
                if let producCode = item.productCode {
                    shoppingCart.removeValue(forKey: producCode)
                    if shoppingCart.count > 0 {
                        navigationItem.leftBarButtonItem = editButtonItem
                    }
                    updateTotalAmount(item, isDelete: true)
                    if shoppingCart.count < 1 {
                        trashBarButtonItem.isEnabled = false
                        editButtonItem.isEnabled = false
                        printButton.isEnabled = false
                    }
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

// MARK: - ShoppingBasketViewControllerDelegate

extension ShoppingBasketViewController: ShoppingBasketViewControllerDelegate {
    
    // Append new items to the shopping cart
    
    func didSelectItems(items: [String : Inventory]) {
        for (key, value) in items {
            shoppingCart[key] = value
        }
        navigationController?.popViewController(animated: true)
    }
}

