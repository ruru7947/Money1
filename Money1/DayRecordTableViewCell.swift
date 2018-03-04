//
//  DayRecordTableViewCell.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/7/24.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class DayRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var annotationLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
