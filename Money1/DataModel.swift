//
//  DataModel.swift
//  Money1
//
//  Created by 梁宏儒 on 25/02/2018.
//  Copyright © 2018 ruru. All rights reserved.
//

import Foundation

struct Record {
    var id :Int = 0
    var item:String = ""
    var date:String = ""
    var time:String = ""
    var image:String = ""
    var location:String = ""
    var amount:Double = 0
    var year:String = ""
    var month:String = ""
    var annotation:String = ""
    var accountID: Int = 0
}

struct Account {
    var id: Int = 1
    var title: String = "現金"
    var balance: Double = 0
	var initAmount: Double = 0
}
