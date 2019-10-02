//
//  InventoryEntryViewController.swift
//  Shopper
//
//  Created by Gene Backlin on 9/16/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit


class InventoryEntryViewController: UIViewController {
    @IBOutlet weak var productCodeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var importedSwitch: UISwitch!

    var selectedTextField: UITextField?
    var delegate: InventoryTableViewControllerDelegate?

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - @IBAction methods
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        if productCodeTextField.text != nil && productCodeTextField.text != "" &&
            descriptionTextField.text != nil && descriptionTextField.text != "" &&
            priceTextField.text != nil && priceTextField.text != "" &&
            taxTextField.text != nil && taxTextField.text != "" {
            aadItemToCoreData()
        } else {
            let alertController = UIAlertController(title: "Invalid Entry", message: "Please ensure all fields are entered !", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Utility methods
    
    func refreshTextFields() {
        productCodeTextField.text = ""
        descriptionTextField.text = ""
        priceTextField.text = ""
        taxTextField.text = ""
        importedSwitch.isOn = false
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

// MARK: - Core Data

extension InventoryEntryViewController {
    func aadItemToCoreData() {
        var inventory = [String : AnyObject]()
        
        inventory[PRODUCT_CODE] = productCodeTextField.text as AnyObject?
        inventory[ITEM_DESCRIPTION] = descriptionTextField.text as AnyObject?
        inventory[PRICE] = Double(priceTextField.text!)! as AnyObject
        inventory[TAX] = Double(taxTextField.text!)! as AnyObject
        inventory[IMPORTED] = importedSwitch.isOn as AnyObject
        refreshTextFields()

        delegate?.itemWillSave(item: inventory)
        selectedTextField?.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension InventoryEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        aadItemToCoreData()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }
}
