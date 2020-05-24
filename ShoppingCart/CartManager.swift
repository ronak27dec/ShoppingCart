//
//  CartManager.swift
//  ShoppingCart
//
//  Created by IITC-MACBOOK02 on 09/03/17.
//  Copyright © 2017 Intelegencia. All rights reserved.
//

import UIKit
import CoreData

class CartManager: NSObject {

    static let shared = CartManager()
    public var totalAmount: Int = 0
    public var totalCartCount: Int = 0

    func addToCart(object: Product) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        if (isItemExist(itemID: object.itemID!)) {
            let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Cart", in: context)!
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            request.entity = entityDesc

            do {
                let resultPredicate = NSPredicate(format: "selectedID==%@", object.itemID!)
                request.predicate = resultPredicate;
                let result = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Cart]
                print(result)

                let selectedIdx = result[0]
                let quantity = Int(selectedIdx.selectedQuantity!)! + 1
                print(quantity)
                selectedIdx.selectedQuantity = String(quantity)

            } catch let error as NSError {
                print("**ERROR** Fetch failed: \(error.localizedDescription)")
            }

            appDelegate.saveContext()

        } else {
            let cart: Cart = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context) as! Cart

            if let selectedName = object.itemName as String? {
                print(selectedName)
                cart.selectedName = selectedName
            } else {
                print("**ERROR** Name is nil")
            }

            if let selectedPrice = object.itemPrice as String? {
                print(selectedPrice)
                cart.selectedPrice = selectedPrice
            } else {
                print("**ERROR** Price is nil")
            }

            if let selectedQuantity = object.itemQuantity as String? {
                print(selectedQuantity)
                let selected: Int = Int(object.itemID!)!
                let totalQ = Int(Items.shared.quantityArray[selected - 1])
                let quantity = (totalQ! + 1) - Int(object.itemQuantity!)!
                cart.selectedQuantity = String(quantity)
            } else {
                print("**ERROR** quantity is nil")
            }

            if let selectedID = object.itemID as String? {
                print(selectedID)
                cart.selectedID = selectedID
            } else {
                print("**ERROR** quantity is nil")
            }
        }
        
        appDelegate.saveContext()
    }

    func removeFromCart(object: Cart) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let entityD: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Product", in: context)!
        let fRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fRequest.entity = entityD

        do {
            let resultPredicate = NSPredicate(format: "itemID==%@", object.selectedID!)
            fRequest.predicate = resultPredicate;
            var result = try context.fetch(fRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Product]
            print(result)

            if (result.count == 0) {
                updateProduct(object: object)
            } else {
                let selectedIdx = result[0]
                let quantity = Int(selectedIdx.itemQuantity!)! + 1
                print(quantity)
                selectedIdx.itemQuantity = String(quantity)
                appDelegate.saveContext()
                result = try context.fetch(fRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Product]
                print(result)
            }
        } catch let error as NSError {
            print("**ERROR** Fetch failed: \(error.localizedDescription)")
        }
    }

    // need to fix this bugs soon.
    private func updateProduct(object: Cart) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Cart", in: context)!
        let request: NSFetchRequest<Cart> = Cart.fetchRequest()
        request.entity = entityDesc

        do {
            var result = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Cart]
            let selectedIdx = result[0]

            let itemName = selectedIdx.selectedName
            let itemID = selectedIdx.selectedID
            let itemPrice = selectedIdx.selectedPrice

            let integerID = Int(itemID!)

            let product: Product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
            product.itemName = itemName
            product.itemID = itemID
            product.itemPrice = itemPrice
            product.itemQuantity = Items.shared.quantityArray[integerID! - 1]

            appDelegate.saveContext()

        } catch let error as NSError {
            print("**ERROR** Fetch failed: \(error.localizedDescription)")
        }
    }

    private func isItemExist(itemID: String) -> Bool {
        var isExist = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Cart", in: context)!
        let request: NSFetchRequest<Cart> = Cart.fetchRequest()
        request.entity = entityDesc

        do {
            let resultPredicate = NSPredicate(format: "selectedID==%@", itemID)
            request.predicate = resultPredicate;
            let result = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Cart]

            if (result.isEmpty) {
                isExist = false
            } else {
                isExist = true
            }
        } catch let error as NSError {
            print("**ERROR** Fetch failed: \(error.localizedDescription)")
        }

        return isExist
    }
}
