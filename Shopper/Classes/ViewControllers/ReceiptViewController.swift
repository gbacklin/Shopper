//
//  ReceiptViewController.swift
//  Shopper
//
//  Created by Gene Backlin on 9/16/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//
// This view controller provides receipt production and processing
// for Inventory items that have been purchased.
//
// Receipt options are:
//      - Preview the receipt
//      - Emailing a pdf version of the receipt
//

import UIKit

class ReceiptViewController: UIViewController {
    @IBOutlet weak var webPreview: UIWebView!

    var HTMLContent: String?
    var pathToReceiptHTMLTemplate: String?
    var receiptNumber: Int?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webPreview.loadHTMLString(HTMLContent!, baseURL: NSURL(string: pathToReceiptHTMLTemplate!)! as URL)
    }
    
    // MARK: - @IBAction methods

    @IBAction func chooseSendOptions(_ sender: UIBarButtonItem) {
        if let html = HTMLContent {
            ReceiptController.shared.exportHTMLContentToPDF(HTMLContent: html)
            showReceiptOptionsAlert()
        }
    }
    
    // MARK: - UIAlertController (Receipt processing)
    
    func showReceiptOptionsAlert() {
        let alertController = UIAlertController(title: "Options", message: "Your receipt has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: .alert)

        let actionPreview = UIAlertAction(title: "Preview it", style: .default) { (action) in
            let request = NSURLRequest(url: NSURL(string: pdfFilename)! as URL)
            self.webPreview.loadRequest(request as URLRequest)
        }
        let actionEmail = UIAlertAction(title: "Send by Email", style: .default) {[weak self] (action) in
            ReceiptController.shared.sendEmail(weakSelf: self!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }

        alertController.addAction(actionPreview)
        if canSendMail {
            alertController.addAction(actionEmail)
        }
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
}


