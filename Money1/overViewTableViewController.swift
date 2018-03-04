//
//  overViewTableViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/14.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class overViewTableViewController: UITableViewController {
    
    var days :[String]! = []
    var myRecords :[String:[[String:String]]]! = [:]
    
    var overviewYear:String!
    var overviewMonth:String!
    var overviewCategory:String!
    var overviewDate:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        overviewYear = myUserDefaults.string(forKey: "overviewYear")
        overviewMonth = myUserDefaults.string(forKey: "overviewMonth")
        overviewCategory = myUserDefaults.string(forKey: "overviewCategory")
        overviewDate = myUserDefaults.string(forKey: "overviewDate")
        
        title = overviewCategory ?? overviewDate
        
        //tableView 外觀
        tableView.tableFooterView = UIView(frame: CGRect.zero) //消除多餘的分隔線
        tableView.separatorStyle = .singleLine

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        updateRecordsList()
    }
    
    //更新列表
    func updateRecordsList(){
        if let myDB = db {
            
            days = []
            myRecords = [:]
            
            if overviewYear != nil && overviewMonth != nil && overviewCategory != nil {
                let statement = myDB.fetch("records", column: nil, cond: "year == '\(overviewYear!)' AND month == '\(overviewMonth!)' AND item == '\(overviewCategory!)'", order: "order by date desc")
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let item = String(cString: sqlite3_column_text(statement, 1))
                    let date = String(cString: sqlite3_column_text(statement, 2))
                    let time = String(cString: sqlite3_column_text(statement, 3))
                    let image = String(cString: sqlite3_column_text(statement, 4))
                    let location = String(cString: sqlite3_column_text(statement, 5))
                    let amount = sqlite3_column_double(statement, 6)
                    let year = String(cString: sqlite3_column_text(statement, 7))
                    let month = String(cString: sqlite3_column_text(statement, 8))
                    let annotation = String(cString: sqlite3_column_text(statement, 9))
 
                    if !days.contains(date) {
                        days.append(date)
                        myRecords[date] = []
                        
                    }
                    myRecords[date]?.append([
                        "id":"\(id)",
                        "item":"\(item)",
                        "date":"\(date)",
                        "time":"\(time)",
                        "image":"\(image)",
                        "location":"\(location)",
                        "amount":"\(amount.clean)",
                        "year":"\(year)",
                        "month":"\(month)",
                        "annotation":"\(annotation)"
                        ])
                }
                sqlite3_finalize(statement)
                
            } else if overviewDate != nil {
                let statement = myDB.fetch("records", column: nil, cond: "date == '\(overviewDate!)'", order: "order by date desc")
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let item = String(cString: sqlite3_column_text(statement, 1))
                    let date = String(cString: sqlite3_column_text(statement, 2))
                    let time = String(cString: sqlite3_column_text(statement, 3))
                    let image = String(cString: sqlite3_column_text(statement, 4))
                    let location = String(cString: sqlite3_column_text(statement, 5))
                    let amount = sqlite3_column_double(statement, 6)
                    let year = String(cString: sqlite3_column_text(statement, 7))
                    let month = String(cString: sqlite3_column_text(statement, 8))
                    let annotation = String(cString: sqlite3_column_text(statement, 9))
                    
                    if !days.contains(date) {
                        days.append(date)
                        myRecords[date] = []
                    }
                    myRecords[date]?.append([
                        "id":"\(id)",
                        "item":"\(item)",
                        "date":"\(date)",
                        "time":"\(time)",
                        "image":"\(image)",
                        "location":"\(location)",
                        "amount":"\(amount.clean)",
                        "year":"\(year)",
                        "month":"\(month)",
                        "annotation":"\(annotation)"
                        ])
                }
                sqlite3_finalize(statement)
            }
            if days.count == 0 {
                self.navigationController?.popViewController(animated: true)
            }
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        print("days.count = \(days.count)")
        return days.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let date = days[section]
        guard let records = myRecords[date] else {
            return 0
        }
        return records.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DayRecordTableViewCell
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return cell
        }
        cell.timeLabel.text = String(records[indexPath.row]["time"]!)
        cell.categoryImage.image = UIImage(named: records[indexPath.row]["image"]!)
        cell.categoryName.text = String(records[indexPath.row]["item"]!)
        cell.amount.text = "$" + String(records[indexPath.row]["amount"]!)
        cell.locationLabel.text = records[indexPath.row]["location"]
        cell.annotationLabel.text = records[indexPath.row]["annotation"]
        return cell
    }
    
    // MARK - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return
        }
        
        myUserDefaults.set(Int(records[indexPath.row]["id"]!), forKey: "postID")
        myUserDefaults.set(nil, forKey: "isvalue")
        myUserDefaults.set(nil, forKey: "name")
        myUserDefaults.set(nil, forKey: "image")
        myUserDefaults.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style:.default, title: "刪除") { (action, indexPath) in
            let date = self.days[indexPath.section]
            guard let records = self.myRecords[date] else {
                return
            }
            
            if let id = records[indexPath.row]["id"],
                let mydb = db {
                
                let statement = mydb.fetch("records", column: nil, cond: "id == \(id)", order: nil)
                var amount: Double = 0
                var accountID: Int = 0
                if sqlite3_step(statement) == SQLITE_ROW {
                    amount = sqlite3_column_double(statement, 6)
                    accountID = Int(sqlite3_column_int(statement, 10))
                }
                sqlite3_finalize(statement)
                
                let statement2 = mydb.fetch("accounts", column: nil, cond: "id == \(accountID)", order: nil)
                var balance: Double = 0
                if sqlite3_step(statement2) == SQLITE_ROW {
                    balance = sqlite3_column_double(statement2, 2)
                    balance += amount
                }
                sqlite3_finalize(statement2)
                let rowInfo = ["balance":"\(balance)"]
                
                _ = mydb.update("accounts", cond: "id == \(accountID)", rowInfo: rowInfo)
                _ = mydb.delete("records", cond: "id = \(id)")
            }
            self.myRecords[date]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateRecordsList()
        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return days[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        headerView.backgroundView?.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
    }

}
