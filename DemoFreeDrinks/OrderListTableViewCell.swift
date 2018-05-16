//
//  OrderListTableViewCell.swift
//  DemoFreeDrinks
//
//  Created by Chao Shin on 2018/5/10.
//  Copyright © 2018 Chao Shin. All rights reserved.
//

import UIKit

class OrderListTableViewCell: UITableViewCell {
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var teaLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var sugerLabel: UILabel!
    @IBOutlet var iceLabel: UILabel!
    @IBOutlet var noteLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    var information: OrderInformation!
  
    func updateUI(id: Int ){
        numberLabel.text = "#\(id + 1)"
        nameLabel.text = "訂購者：\(information.name)"
        teaLabel.text = "飲料：\(information.tea)"
        sizeLabel.text = "容量：\(information.size)"
        sugerLabel.text = "甜度：\(information.sugar)"
        iceLabel.text = "冰度：\(information.ice)"
        noteLabel.text = "備註：\(information.note)"
        priceLabel.text = "金額：\(information.price)"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
