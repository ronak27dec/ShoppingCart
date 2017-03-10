//
//  ProductsViewController.swift
//  ShoppingCart
//
//  Created by IITC-MACBOOK02 on 09/03/17.
//  Copyright © 2017 Intelegencia. All rights reserved.
//

import UIKit
import CoreData

struct NavigationTitle {
    static let Products = "Products"
    static let MyCart = "MyCart"
}

struct CellHeight {
    static let height = 100
}

class ProductsViewController: UIViewController {

    var productArray: Array<Product>!
    var selectedProduct: Array<Cart>!

    var cart : UIBarButtonItem!
    var amount : UIBarButtonItem!

    var selectedItemID : String!

    @IBOutlet weak var productTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NavigationTitle.Products

        configureTableView()
        configureRightBar()
        configureLeftBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadProducts()
    }

    private func configureTableView() {
        productTable.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        productTable.delegate = self
        productTable.dataSource = self
        productTable.showsVerticalScrollIndicator = false
    }

    func loadProducts() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Product", in: context)!
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.entity = entityDesc

        do {
            productArray = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Product]
            print(productArray.count)
        } catch let error as NSError {
            print("**ERROR** Fetch failed: \(error.localizedDescription)")
        }

        updateBarText()

        productTable.reloadData()
    }

    func updateEntity() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Product", in: context)!
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.entity = entityDesc

        do {
            let resultPredicate = NSPredicate(format: "itemID==%@", selectedItemID)
            request.predicate = resultPredicate;
            let result = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Product]
            print(result)

            let selectedIdx = result[0]
            let quantity = Int(selectedIdx.itemQuantity!)! - 1
            print(quantity)
            selectedIdx.itemQuantity = String(quantity)
        } catch let error as NSError {
            print("**ERROR** Fetch failed: \(error.localizedDescription)")
        }

        appDelegate.saveContext()
        
        loadProducts()
    }

    private func configureRightBar() {
        cart = UIBarButtonItem(title: "0", style: .plain, target: self, action: #selector(pushToCartView))
        self.navigationItem.rightBarButtonItem = cart
    }

    private func configureLeftBar() {
        amount = UIBarButtonItem(title: "Rs. 0", style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = amount
    }

    @objc private func pushToCartView() {
        NavigationManager.pushToCart()
    }

    func addToCart(sender: AnyObject) {
        let product = productArray[sender.tag]
        selectedItemID = product.itemID

        let availableQ = Int(product.itemQuantity!)
        if (availableQ! == 0) {
            productTable.reloadData()
            return
        }

        // Update Total count & Total Amount here
        CartManager.shared.totalCartCount += 1
        CartManager.shared.totalAmount = Int(product.itemPrice!)! + CartManager.shared.totalAmount

        CartManager.shared.addToCart(object: product)
        updateEntity()
        updateBarText()
    }

    func updateBarText() {
        cart.title = String(CartManager.shared.totalCartCount)
        amount.title = String(format: "Rs \(CartManager.shared.totalAmount)")
    }
}

extension ProductsViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CellHeight.height)
    }
}

extension ProductsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ProductCell"
        var cell: ProductCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as! ProductCell
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ProductCell
        }

        cell.selectionStyle = .none;

        let product = productArray[indexPath.row]
        cell.name.text = product.itemName
        cell.price.text = product.itemPrice

        if (Int(product.itemQuantity!) == 0) {
            cell.quantity.text = "Out of Stock"
        } else {
            cell.quantity.text = product.itemQuantity
        }
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(self.addToCart(sender:)), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return productArray.count
    }
}
