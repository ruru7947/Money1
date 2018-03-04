//
//  AnnotationViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/20.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class AnnotationViewController: UIViewController {

    @IBOutlet weak var annotationTextField: UITextView!
    
    weak var viewController:ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        annotationTextField.becomeFirstResponder()
        if viewController.isRecordSave == true {
            annotationTextField.text = ""
        } else {
            annotationTextField.text = viewController.record.annotation
        }
    }
 
    @IBAction func okButton(_ sender: FancyButton) {
        annotationTextField.resignFirstResponder()
        viewController.isRecordSave = false
        viewController.record.annotation = annotationTextField.text
        dismiss(animated: true, completion: nil)
    }

}
