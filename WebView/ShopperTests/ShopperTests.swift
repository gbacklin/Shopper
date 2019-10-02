//
//  ShopperTests.swift
//  ShopperTests
//
//  Created by Gene Backlin on 9/17/19.
//  Copyright © 2019 Gene Backlin. All rights reserved.
//

import XCTest

class ShopperTests: XCTestCase {
    let inventoryController: InventoryController = InventoryController()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddInventoryItem() {
        let productCode = "CODE1"
        let itemDescription = "Code 1 description"
        let price = 9.99
        let tax = 0.1
        let isImported = false

        inventoryController.addInventoryItem(productCode: productCode, itemDescription: itemDescription, price: price, tax: tax, isImported: isImported)
        let count = inventoryController.inventoryCount
        XCTAssert(count == 1)
    }

}
