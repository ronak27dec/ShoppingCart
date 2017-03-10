//
//  ProductCell.swift
//  ShoppingCart
//
//  Created by IITC-MACBOOK02 on 09/03/17.
//  Copyright © 2017 Intelegencia. All rights reserved.

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var addButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
