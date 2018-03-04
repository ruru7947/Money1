//
//  ExtensionDouble.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/9/5.
//  Copyright © 2017年 ruru. All rights reserved.
//

import Foundation

extension Double {
    var clean: String {
        //除以一的餘數，如果等於0代表沒有小數點，去掉小數點.0，不等於零代表有小數點，則取小數點後兩位
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)    }
}
