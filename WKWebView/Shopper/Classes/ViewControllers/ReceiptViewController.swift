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
import WebKit

class ReceiptViewController: UIViewController {
    @IBOutlet var webPreviewWK: WKWebView!
    @IBOutlet var optionsBarButtonItem: UIBarButtonItem!
    //@IBOutlet weak var webPreview: UIWebView!

    var HTMLContent: String?
    var pathToReceiptHTMLTemplate: String?
    var receiptNumber: Int?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webPreviewWK.loadHTMLString(HTMLContent!, baseURL: NSURL(string: pathToReceiptHTMLTemplate!)! as URL)
        webPreviewWK.navigationDelegate = self
    }
    
    // MARK: - @IBAction methods

    @IBAction func chooseSendOptions(_ sender: UIBarButtonItem) {
        if let html = HTMLContent {
            let filename = ReceiptController.shared.exportHTMLContentToPDF(HTMLContent: html)
            showReceiptOptionsAlert(filename)
        }
    }
    
    // MARK: - UIAlertController (Receipt processing)
    
    func showReceiptOptionsAlert(_ filename: String) {
        let alertController = UIAlertController(title: "Options", message: "Your receipt has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: .alert)

        let actionPreview = UIAlertAction(title: "Print it", style: .default) {[weak self] (action) in
            self!.webPreviewWK.printPDF(path: filename, printButton: self!.optionsBarButtonItem)
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
    
    func webViewToImage() {
        let config = WKSnapshotConfiguration()
        config.rect = CGRect(x: 0, y: 0, width: 150, height: 50)

        webPreviewWK.takeSnapshot(with: config) { image, error in
            if let image = image {
                print(image.size)
            }
        }
    }

}

extension UIViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
