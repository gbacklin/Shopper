//
//  ReceiptController.swift
//  Shopper
//
//  Created by Gene Backlin on 9/17/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

let pathToReceiptHTMLTemplate = Bundle.main.path(forResource: "invoice", ofType: "html")
let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_item", ofType: "html")
let pathToLastItemHTMLTemplate = Bundle.main.path(forResource: "last_item", ofType: "html")
let senderInfo = "My Great Store<br>123 Normal Str.<br>10000 - Normal<br>USA"
let dueDate = ""
let paymentMethod = "Net 30"
let logoImageURL = ""
var receiptNumber: String!
var pdfFilename: String!
var currencyFormatter: NumberFormatter {
    get {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }
}
var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}
var docDirectory: String {
    get {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
}
var canSendMail: Bool {
    get {
        return MFMailComposeViewController.canSendMail()
    }
}

class ReceiptController: NSObject {
    static let shared = ReceiptController()
    
    var receiptNumber: String?
    
    // MARK: - PDF production

    func renderReceipt(receiptNumber: String, invoiceDate: String, recipientInfo: String?, items: [String : Inventory], subTotalAmount: String, taxAmount: String, totalAmount: String, shoppingCart: [String : Inventory]) -> String! {
        
        // Store the invoice number for future use.
        self.receiptNumber = receiptNumber

        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToReceiptHTMLTemplate!)

            // Replace all the placeholders with real values except for the items.
            // Receipt number.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_NUMBER#", with: receiptNumber)

            // Receipt date.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_DATE#", with: invoiceDate)

            // Due date (we leave it blank by default).
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DUE_DATE#", with: dueDate)

            // Sender info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SENDER_INFO#", with: senderInfo)

            // Tax amount.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SUBTOTAL_AMOUNT#", with: subTotalAmount)
            
            // Tax amount.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL_TAX#", with: taxAmount)
            
            // Total amount.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL_AMOUNT#", with: totalAmount)

            // The invoice items will be added by using a loop.
            var allItems = ""
            
            // For all the items except for the last one we'll use the "single_item.html" template.
            // For the last one we'll use the "last_item.html" template.
            let keys = Array(shoppingCart.keys)
            for i in 0..<shoppingCart.count {
                var itemHTMLContent: String!
                let key = keys[i]
                if let item: Inventory = shoppingCart[key] {
                    
                    // Determine the proper template file.
                    if i != shoppingCart.count - 1 {
                        itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                    } else {
                        itemHTMLContent = try String(contentsOfFile: pathToLastItemHTMLTemplate!)
                    }
                    
                    // Replace the description and price placeholders with the actual values.
                    itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: item.itemDescription!.description)
                    
                    // Format each item's price as a currency value.
                    let price = item.price as NSNumber
                    if let formattedPrice: String = currencyFormatter.string(from: price) {
                        itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PRICE#", with: formattedPrice)
                    }
                    
                    // Add the item's HTML code to the general items string.
                    allItems += itemHTMLContent
                }
            }
            
            // Set the items.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
            HTMLContent = HTMLContent.replacingOccurrences(of: "\n", with: "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "\t", with: "")
            // The HTML code is ready.
            return HTMLContent
        } catch {
            print("Unable to open and use HTML template files.")
        }
        return nil
    }

    func exportHTMLContentToPDF(HTMLContent: String) {
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)

        pdfFilename = "\(docDirectory)/Receipt\(receiptNumber!).pdf"
        pdfData?.write(toFile: pdfFilename, atomically: true)
        
        print(pdfFilename!)
    }

    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }

    // MARK: - Utility
    
    func sendEmail(weakSelf: ReceiptViewController) {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setSubject("Receipt # \(receiptNumber!)")
        mailComposeViewController.addAttachmentData(NSData(contentsOfFile: pdfFilename)! as Data, mimeType: "application/pdf", fileName: "Receipt")
        weakSelf.present(mailComposeViewController, animated: true, completion: nil)
    }

}
// MARK: - MFMailComposeViewControllerDelegate

extension ReceiptController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
