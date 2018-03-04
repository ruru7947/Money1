//
//  monthRecordTableViewCell.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/11.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class monthRecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var CategoryAndDateImage:UIImageView!
    @IBOutlet weak var CategoryAndDateLabel:UILabel!
    @IBOutlet weak var amountLabel:UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
