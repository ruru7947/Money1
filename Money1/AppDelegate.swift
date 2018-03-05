//
//  AppDelegate.swift
//  Money1
//
//  Created by ruru on 2017/7/24.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit
import GooglePlaces

let myUserDefaults = UserDefaults.standard
var db: SQLiteConnect!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var setupTableViewController:SetupTableViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSPlacesClient.provideAPIKey("AIzaSyAMxmikwWhwQ8yjJq-havRUP4CkT6MCvh8")
        
        
        let dbInit = myUserDefaults.object(forKey: "dbInit") as? Int
        if dbInit == nil {
            let dbFileName = "sqlite3.db"
            db = SQLiteConnect(file: dbFileName)
            if let myDB = db {
                let result = myDB.createTable("records", columnsInfo: [
                    "id integer primary key autoincrement",
                    "item text",
                    "date text",
                    "time text",
                    "image text",
                    "location text",
                    "amount int",
                    "year text",
                    "month text",
                    "annotation text",
                    "accountid int"
                    ])
                
                let category = myDB.createTable("categories", columnsInfo: [
                    "id integer primary key autoincrement",
                    "image text",
                    "name text"
                    ])
                
                let accounts = myDB.createTable("accounts", columnsInfo: [
                    "id integer primary key autoincrement",
                    "accountname text",
                    "balance int",
					"initAmount int"
                    ])
                
                if result && category && accounts { //createTable執行成功會回傳true
                    
                    //加入accounts預設資料
                    let accountDic = ["現金":"0"]
                    
                    //加入category預設資料
                    let categories = ["生病":"doctor","學習":"book2","社交":"gift","寵物":"pet","旅行":"travel","運動":"exercise","計程車":"taxi","娛樂":"happy","日常用品":"house","食物":"food","交通":"bus","外食":"food3","飲料":"drink"]
                    
                    for (name, image) in categories {
                        let rowInfo = ["name":"'\(name)'","image":"'\(image)'"]
                        let insertSuccess = myDB.insert("categories", rowInfo:rowInfo)
                        if insertSuccess {
                            print("categories加入成功")
                        }
                    }
                    
                    for (name, balance) in accountDic {
						let Info = ["accountname":"'\(name)'", "balance":"\(balance)", "initAmount":"0"]
                        let insertSuccess = myDB.insert("accounts", rowInfo:Info )
                        if insertSuccess {
                            print("accounts加入成功")
                        }
                    }
                    
                    //將key為dbInit的值設為1，表示已經執行過，下次執行程式的時候就不會進入建立資料表
                    myUserDefaults.set(1, forKey: "dbInit")
                    //將key為dbFileName的值設為dbFileName（sqlite3.db）
                    myUserDefaults.set(dbFileName, forKey: "dbFileName")
					myUserDefaults.set("現金", forKey: "defaultAccountName")
                    myUserDefaults.synchronize() //同步，會寫入任何的新增或修改

                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
		
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
		let hasPassword = myUserDefaults.bool(forKey: "hasPassword")
		if hasPassword {
			self.window?.rootViewController?.performSegue(withIdentifier: "LoginSegue", sender: self)
		}
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

