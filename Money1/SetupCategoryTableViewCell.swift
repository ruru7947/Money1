//
//  SetupCategoryTableViewCell.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/18.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class SetupCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var isAddAcocuntPage: Bool = true {
        didSet {
            categoryImage?.isHidden = isAddAcocuntPage
            balanceLabel?.isHidden = !isAddAcocuntPage
        }
    }
	
	var categoryToSet: CategoryToSet = .setAccount {
		didSet {
			switch categoryToSet {
			case .setItem:
				categoryImage?.isHidden = false
				balanceLabel?.isHidden = true
				
			case .setAccount:
				categoryImage?.isHidden = true
				balanceLabel?.isHidden = false
				
			case .setPassword:
				categoryImage?.isHidden = true
				balanceLabel?.isHidden = true
			}
		}
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
