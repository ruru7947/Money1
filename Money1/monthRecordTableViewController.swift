//
//  monthRecordTableViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/11.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit
//import Charts

class monthRecordTableViewController: UITableViewController/*,ChartViewDelegate*/ {
    
    var year:String! // = myUserDefaults.string(forKey: "month")! 為何把直設在這邊會跟設在viewDidLoad裡不一樣，
    var month:String! //  = myUserDefaults.string(forKey: "month")! 設在這邊title會不同步（慢一步）？
    
    var categoryArr:[String] = []
    var day:[String] = []
    var yearMonthCategory:[String:[String:String]] = [:]
    var yearMonthDay:[String:[String:String]] = [:]
    let colors: NSMutableArray! = []
//    let format = NumberFormatter()
    
//    @IBOutlet weak var chartView: PieChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        year = myUserDefaults.string(forKey: "year")!
        month = myUserDefaults.string(forKey: "month")!
        self.title = year + "年" + month + "月"

        //tableView 外觀
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero) //消除多餘的分隔線
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
        
//        chartView.usePercentValuesEnabled = true
//        chartView.drawHoleEnabled = true
//        chartView.chartDescription?.text = ""
//        chartView.holeColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
        
//        colors.addObjects(from: ChartColorTemplates.material())
//        colors.addObjects(from: ChartColorTemplates.colorful())
//        colors.addObjects(from: ChartColorTemplates.liberty())
//        colors.addObjects(from: ChartColorTemplates.vordiplom())
//        colors.addObjects(from: ChartColorTemplates.joyful())
//        colors.add(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        
//        format.numberStyle = .percent
//        format.maximumFractionDigits = 1
//        format.multiplier = 1.0
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        myUserDefaults.set(nil, forKey: "overviewYear")
        myUserDefaults.set(nil, forKey: "overviewMonth")
        myUserDefaults.set(nil, forKey: "overviewCategory")
        myUserDefaults.set(nil, forKey: "overviewDate")
        
        updateRecordsList()
    }


    func updateRecordsList() {
        
//        var categories:[String] = []
//        var totalAmount:[Double] = []
        var totala = 0.0
        
        if let myDB = db {
            categoryArr = []
            day = []
            yearMonthCategory = [:]
            yearMonthDay = [:]

            let statement = myDB.fetch("records", column: "*,SUM(amount) as 'total'", cond: "month == '\(month!)' AND year == '\(year!)'", order: "GROUP BY item order by total desc")
            while sqlite3_step(statement) == SQLITE_ROW  {

                let id = Int(sqlite3_column_int(statement, 0))
                let item = String(cString: sqlite3_column_text(statement, 1))
                let date = String(cString: sqlite3_column_text(statement, 2))
                let time = String(cString: sqlite3_column_text(statement, 3))
                let image = String(cString: sqlite3_column_text(statement, 4))
                let location = String(cString: sqlite3_column_text(statement, 5))
                let amount = sqlite3_column_double(statement, 6)
                let year = String(cString: sqlite3_column_text(statement, 7))
                let month = String(cString: sqlite3_column_text(statement, 8))
                let total = sqlite3_column_double(statement, 10)
                print([id, item, date, time, image, location, amount, year, month])
                
                totala += total
                
                var monthTotal = 0.0
                var dayTotal = 0.0
                
                if !categoryArr.contains(item) {
                    categoryArr.append(item)
                    yearMonthCategory[item] = [:]

                    let categoryStatement = myDB.fetch("records", column: "item, SUM(amount) as 'total'", cond: "month == '\(month)' AND year == '\(year)' AND item == '\(item)'", order: " order by 'amount' desc")
                    while sqlite3_step(categoryStatement) == SQLITE_ROW {
                        let categoryAmount = sqlite3_column_double(categoryStatement, 1)
                        monthTotal = categoryAmount
                    }
                    sqlite3_finalize(categoryStatement)
                    
                    yearMonthCategory[item] = [
                        "image":"\(image)",
                        "item":"\(item)",
                        "year":"\(year)",
                        "month":"\(month)",
                        "monthTotal":"\(monthTotal.clean)"
                        ]
                }
                
                if !day.contains(date) {
                    day.append(date)
                    yearMonthDay[date] = [:]
                    
                    let dayStatement = myDB.fetch("records", column: nil, cond: "date == '\(date)'", order: " order by date desc")
                    while sqlite3_step(dayStatement) == SQLITE_ROW {
                        let dayAmount = sqlite3_column_double(dayStatement, 6)
                        dayTotal += dayAmount
                    }
                    sqlite3_finalize(dayStatement)
                    
                    yearMonthDay[date] = [
                        "date":"\(date)",
                        "dayTotal":"\(dayTotal.clean)"
                        ]
                }
            }
//            chartView.centerText = "總花費\n" + "$" + totala.clean
//            sqlite3_finalize(statement)
//
//            for var i in categoryArr {
//                let mothCategory = yearMonthCategory[i]
//                if let j = Double((mothCategory?["monthTotal"])!) {
//                    if j != 0.0 {
//                        if j / totala < 0.02 {
//                            i = ""
//                        }
//                        categories.append(i)
//                        totalAmount.append(j)
//                    }
//                }
//            }
        }
        
//        var dataEntries: [PieChartDataEntry] = []
//        for i in 0 ..< categories.count {
//            let dataEntry = PieChartDataEntry(value: totalAmount[i], label: categories[i])
//            dataEntries.append(dataEntry)
//        }
//        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
//        chartDataSet.colors = colors as! [NSUIColor]
//        chartDataSet.accessibilityElementsHidden = true
//        chartDataSet.valueLineVariableLength = true
//        chartDataSet.valueTextColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
//        chartDataSet.yValuePosition = .outsideSlice
//        chartDataSet.valueLineColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        chartDataSet.valueLinePart1Length = 0.3
//        chartDataSet.drawIconsEnabled = true
//        let formatter = DefaultValueFormatter(formatter: format)
//        chartDataSet.valueFormatter = formatter
//        chartDataSet.valueLineVariableLength = true
//        let charData = PieChartData(dataSet: chartDataSet)
//        chartView.data = charData
        
        
        tableView.reloadData()

    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return categoryArr.count}
        if section == 1 {return day.count}

        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! monthRecordTableViewCell
        
        if indexPath.section == 0 {
            let category = categoryArr[indexPath.row]
            if let mothCategory = yearMonthCategory[category] {
                cell.CategoryAndDateImage.image = UIImage(named: mothCategory["image"]!)
                cell.CategoryAndDateLabel.text = mothCategory["item"]
                cell.amountLabel.text = "$" +  mothCategory["monthTotal"]!
                return cell
            }

        }
        
        if indexPath.section == 1 {
            let date = day[indexPath.row]
            if let day = yearMonthDay[date] {
                cell.CategoryAndDateLabel.text = day["date"]
                cell.amountLabel.text = "$" + day["dayTotal"]!
                cell.CategoryAndDateImage.image = UIImage(named: "clock")
                return cell
            }
        }
        
        return cell

    }
 

    // MARK - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let category = categoryArr[indexPath.row]
            if let mothCategory = yearMonthCategory[category] {
                myUserDefaults.set(mothCategory["year"], forKey: "overviewYear")
                myUserDefaults.set(mothCategory["month"], forKey: "overviewMonth")
                myUserDefaults.set(mothCategory["item"], forKey: "overviewCategory")
            }
        }
        
        if indexPath.section == 1 {
            let date = day[indexPath.row]
            if let day = yearMonthDay[date] {
                myUserDefaults.set(day["date"], forKey: "overviewDate")
            }
        }
        myUserDefaults.synchronize()
    }
    
    // section 標題
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if day.count == 0 {
            return ""
        } else {
            if section == 0 {return "類別"}
            if section == 1 {return "日"}
        }
        return ""
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
