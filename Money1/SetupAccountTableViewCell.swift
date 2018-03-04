//
//  SetupAccountTableViewCell.swift
//  Money1
//
//  Created by 梁宏儒 on 28/02/2018.
//  Copyright © 2018 ruru. All rights reserved.
//

import UIKit

class SetupAccountTableViewCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		textField.returnKeyType = .done
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
