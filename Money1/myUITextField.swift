//
//  myUITextField.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/7/26.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class myUITextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        super.addGestureRecognizer(gestureRecognizer)
        if gestureRecognizer is UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false
        }
        
        if gestureRecognizer is UITapGestureRecognizer {
            if gestureRecognizer.numberOfTouches == 2 {
                gestureRecognizer.isEnabled = false
            }
        }
    }
    
    

}
