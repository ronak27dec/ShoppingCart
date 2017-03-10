//
//  AppDelegate.swift
//  ShoppingCart
//
//  Created by IITC-MACBOOK02 on 09/03/17.
//  Copyright © 2017 Intelegencia. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        launcProductScreen()
        clearDB()
        clearCartDB()
        addProducts()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { self.saveContext() }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ShoppingCart")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()


    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private func launcProductScreen() {
        let controller = ProductsViewController(nibName: "ProductsViewController", bundle: nil)
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        navigationController = UINavigationController(rootViewController: controller)
        window!.rootViewController = navigationController
    }

    func addProducts() {
        let count = Items.shared.nameArray.count

        for i in (0..<count) {

            let context = persistentContainer.viewContext
            let product: Product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product

            if let name = Items.shared.nameArray[i] as String? {
                print(name)
                product.itemName = name
            } else {
                print("**ERROR** Name is nil")
            }

            if let price = Items.shared.priceArray[i] as String? {
                print(price)
                product.itemPrice = price
            } else {
                print("**ERROR** Price is nil")
            }

            if let quantity = Items.shared.quantityArray[i] as String? {
                print(quantity)
                product.itemQuantity = quantity
            } else {
                print("**ERROR** quantity is nil")
            }

            if let itemID = Items.shared.itemID[i] as String? {
                print(itemID)
                product.itemID = itemID
            } else {
                print("**ERROR** itemID is nil")
            }

            saveContext()
        }
    }

    func clearDB() {
        let context = persistentContainer.viewContext
        let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Product", in: context)!
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.entity = entityDesc
        if let result = try? context.fetch(request) {
            for object in result {
                context.delete(object)
            }
            saveContext()
        }
    }

    func clearCartDB() {
        let context = persistentContainer.viewContext
        let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Cart", in: context)!
        let request: NSFetchRequest<Cart> = Cart.fetchRequest()
        request.entity = entityDesc
        if let result = try? context.fetch(request) {
            for object in result {
                context.delete(object)
            }
            saveContext()
        }
    }
}

