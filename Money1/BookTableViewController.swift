//
//  BookTableViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/10.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class BookTableViewController: UITableViewController {
    
    var years:[String] = []
    var months:[String] = []
    var yearMonth:[String:[[String:String]]] = [:]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "總覽"
        
        //tableView 外觀
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .singleLine
		tableView.separatorColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        updateRecordsList()
    }
    
    func updateRecordsList() {
        if let myDB = db {
            
            years = []
            months = []
            yearMonth = [:]
            
            let statement = myDB.fetch("records", column: nil, cond: nil, order: " order by date desc")
            while sqlite3_step(statement) == SQLITE_ROW {
                
                let year = String(cString: sqlite3_column_text(statement, 7))
                let month = String(cString: sqlite3_column_text(statement, 8))
                
                let ym = year + month //如果只判斷月份是否有在陣列內，會造成前面的年份無法加入月份
                
                if !years.contains(year) {
                    years.append(year)
                    yearMonth[year] = []
                }
                
                if !months.contains(ym) {
                    months.append(ym)
                    var monthTotal = 0.0
                    let monthStatement = myDB.fetch("records", column: nil, cond: "month == '\(month)' AND year == '\(year)'", order: " order by month desc")
                    while sqlite3_step(monthStatement) == SQLITE_ROW {
                        let amount = sqlite3_column_double(monthStatement, 6)
                        monthTotal += amount
                    }
                    
                    yearMonth[year]?.append([
                        "year":"\(year)",
                        "month":"\(month)",
                        "monthTotal":"\(monthTotal.clean)"
                        ])
                    sqlite3_finalize(monthStatement)
                    
                }
            }
            
            sqlite3_finalize(statement)
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let year = years[section]
        if let month = yearMonth[year] {
            return month.count
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookTableViewCell
        
        let year = years[indexPath.section]
        guard let month = yearMonth[year] else {
            return cell
        }
        
        cell.monthLabel.text = String(format: "%d月", Int(month[indexPath.row]["month"]!)!)
        cell.amountLabel.text = "$" + month[indexPath.row]["monthTotal"]!
        return cell
    }

    // MARK - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let year = years[indexPath.section]
        guard let yearMonth = yearMonth[year] else {
            return
        }
        
        myUserDefaults.set(yearMonth[indexPath.row]["year"], forKey: "year")
        myUserDefaults.set(yearMonth[indexPath.row]["month"], forKey: "month")
        print("\([myUserDefaults.string(forKey: "year"), myUserDefaults.string(forKey: "month")]).......")
        myUserDefaults.synchronize()
        
    }
    // section 標題
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return years[section] + "年"
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
