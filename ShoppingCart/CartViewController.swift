//
//  CartViewController.swift
//  ShoppingCart
//
//  Created by IITC-MACBOOK02 on 09/03/17.
//  Copyright © 2017 Intelegencia. All rights reserved.
//

import UIKit
import CoreData

class CartViewController: UIViewController {

    @IBOutlet weak var cartTable: UITableView!

    var cartArray: Array<Cart>!
    var quantity: Int = 0

    var totalAmount : UIBarButtonItem!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NavigationTitle.MyCart
        configureTableView()
        addTotalAmountButton()
        loadCart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    static func cartView() -> CartViewController {
        let cart = CartViewController()
        return cart
    }

    private func configureTableView() {
        cartTable.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        cartTable.delegate = self
        cartTable.dataSource = self
        cartTable.showsVerticalScrollIndicator = false
    }

    func loadCart() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Cart", in: context)!
        let request: NSFetchRequest<Cart> = Cart.fetchRequest()
        request.entity = entityDesc

        do {
            cartArray = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Cart]
        } catch let error as NSError {
            print("**ERROR** Fetch failed: \(error.localizedDescription)")
        }

        cartTable.reloadData()
    }

    func removeFromCart(sender: AnyObject) {
        let cart = cartArray[sender.tag]

        CartManager.shared.removeFromCart(object: cart)

        // Update Quantity here and save it
        quantity = Int(cart.selectedQuantity!)! - 1

        // Update Total count & Total Amount here
        CartManager.shared.totalCartCount = CartManager.shared.totalCartCount - 1
        CartManager.shared.totalAmount =   CartManager.shared.totalAmount - Int(cart.selectedPrice!)!
        updateAmountText(amount: String(CartManager.shared.totalAmount))
        cart.selectedQuantity = String(quantity)

        if (quantity == 0) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            let entityDesc: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Cart", in: context)!
            let request: NSFetchRequest<Cart> = Cart.fetchRequest()
            request.entity = entityDesc
            context.delete(cart)
            
            appDelegate.saveContext()
        }

        loadCart()
    }

    private func addTotalAmountButton() {
        totalAmount = UIBarButtonItem(title: String(CartManager.shared.totalAmount), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = totalAmount
    }

    private func updateAmountText(amount: String) {
        totalAmount.title = amount
    }
}

extension CartViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CellHeight.height)
    }
}

extension CartViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ProductCell"
        var cell: ProductCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as! ProductCell
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ProductCell
        }

        cell.selectionStyle = .none;

        let cart = cartArray[indexPath.row]
        cell.name.text = cart.selectedName
        cell.price.text = cart.selectedPrice
        cell.quantity.text = cart.selectedQuantity

        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(self.removeFromCart(sender:)), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return cartArray.count
    }
}
