//
//  ViewController.swift
//  Money1
//
//  Created by ruru on 2017/7/24.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit
import  GooglePlaces
import CoreLocation

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var isTodayLabel: UILabel! //用來顯示今日或是年份
    @IBOutlet weak var dateTextField:myUITextField! //顯示日期
    @IBOutlet weak var selectedItemLabel: UILabel!  //顯示選擇的類別
    @IBOutlet weak var dayAmount: UILabel! //單日的總花費
    @IBOutlet weak var monthAmount: UILabel! //月花費
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var subView2: UIView!
    @IBOutlet weak var accountbutton: FancyButton!
    @IBOutlet weak var acccountBalanceLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    
    //資料庫
    let myUserDefaults = UserDefaults.standard
    var days :[String]! = []
    var myRecords :[String:[[String:String]]]! = [:]
    var categories:[String:[[String:String]]]! = [:]
    
    var record = Record()
	var account: Account?
	
    var myDatePicker :UIDatePicker!      //時間選擇器
    let YMDformatter = DateFormatter()   //年月日
    let YMformatter = DateFormatter()
    let MDformatter = DateFormatter()    //月日
    let Yformatter = DateFormatter()     //年
    let Mformatter = DateFormatter()    //月
    
    let timeformater = DateFormatter()   //時間
    var currentDate = Date() //取得時間
    var now = Date() //現在時間
    let numFormatter = NumberFormatter() //格式化數字
    
    var isRecordSave = false
    
    var ItemRow:IndexPath! //儲存collectionView選擇的列
    
    var isAddingNewRow: Bool = false
    
    //位置
    var placesClient:GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    //計算機
    @IBOutlet fileprivate weak var display: UILabel!  //顯示機算幾輸入的金額
    @IBOutlet fileprivate weak var descriptionLabel: UILabel! //暫時不用
    
    fileprivate var brain = CalculatorBrain() //實體化機算幾內部處理的類別
    fileprivate var userIsInTheMiddleOfTyping = false //是否有輸入過，預設沒有輸入過
    fileprivate let DECIMAL_CHAR = "." //小數點
    fileprivate var displayValue: Double {
        get { return Double(display.text!)! }
        set { display.text = newValue.clean }
        
    }
    
    //第一次顯示畫面時會呼叫
    override func viewDidLoad() {
        super.viewDidLoad()

		let hasPassword = myUserDefaults.bool(forKey: "hasPassword")
		if hasPassword {
			UIView.performWithoutAnimation {
				navigationController?.performSegue(withIdentifier: "LoginSegue", sender: nil)
			}
		}
		
		myUserDefaults.set(nil, forKey: "userSelectedAccount") //使用者選擇的帳戶(非預設帳戶)
		
        placesClient = GMSPlacesClient.shared()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //資料庫連線
        if myUserDefaults.object(forKey: "dbInit") as? Int != nil {
            let dbFileName = myUserDefaults.object(forKey: "dbFileName") as! String
            db = SQLiteConnect(file: dbFileName)
        }
        
        title = "記帳" //navigationbar上的title
        selectedItemLabel.text = "請選擇類別"
        
        //subView外
        subView.layer.borderWidth = 1
        subView.layer.borderColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1).cgColor
        subView2.layer.borderWidth = 0
        subView2.layer.borderColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1).cgColor

        //tableView 外觀
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero) //消除多餘的分隔線
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = #colorLiteral(red: 1, green: 1, blue: 0.966417002, alpha: 1)
        
        //設定collectionView為不能多選的狀態
        collectionView.allowsMultipleSelection = false
        
        //格式化數字
		numFormatter.numberStyle = .decimal

        
        //ToolBar 放在日期選擇器上，點擊日期標籤時會跟日期選擇器一起彈出
        let ToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let SpaceLeft = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem.init(title: "確定", style: .done, target: self, action: #selector(selectTimeClick))
        let todayButton = UIBarButtonItem.init(title: "今天", style: .done, target: self, action: #selector(todayButtonClick))
        todayButton.tintColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1)
        doneButton.tintColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1)
        ToolBar.setItems([todayButton,SpaceLeft,doneButton], animated: true) //加上按鈕
        
        //日期選擇器
        myDatePicker = UIDatePicker() //實體化
        myDatePicker.datePickerMode = .date //設定時間選擇器的模式
        myDatePicker.locale = Locale(identifier: "zh_TW") //時區，台灣
        myDatePicker.window?.makeKey()
        myDatePicker.backgroundColor = UIColor.white
        myDatePicker.setValue(#colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1), forKey: "textColor")
        
        //點擊彈出日期選擇器
        dateTextField.inputView = myDatePicker
        dateTextField.inputAccessoryView = ToolBar
        
        //格式化日期字串
        timeformater.dateFormat = "HH:mm"
        MDformatter.dateFormat = "MM/dd"
        YMDformatter.dateFormat = "YY-MM-dd"
        YMformatter.dateFormat = "YY-MM"
        Mformatter.dateFormat = "MM"
        Yformatter.dateFormat = "YYYY"
        
        //日期顯示
        dateTextField.text = MDformatter.string(from: currentDate)
        if YMDformatter.string(from: currentDate) == YMDformatter.string(from: myDatePicker.date) {
            isTodayLabel.text = "今天"
        } else {
            dateTextField.text = MDformatter.string(from: myDatePicker.date)
            isTodayLabel.text = ""
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.allowsMultipleSelection = false
        self.tabBarController?.tabBar.isHidden = false
        
        //詢問使用者
        locationManager.requestWhenInUseAuthorization()
        
        //獲取位置
        if ((CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)
            && CLLocationManager.locationServicesEnabled()){
            placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoodList {
                    let place = placeLikelihoodList.likelihoods.first?.place
                    if let place = place {
                        print("我有拿到地址")
                        self.record.location = place.name
                        print(self.record.location)
                    }
                }
            })
        } else {
            record.location = ""
        }
		getDefaultAccount()
        updateAccountList()
        updateRecordsList()
        updateCategoryList()
    }
    
    //MARK: - UICollectionViewDataSource
    //顯示列的時候呼叫
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        guard let categories = categories["categories"] else {
            return cell
        }
        
        cell.CategoryName.text = String(categories[indexPath.row]["name"]!)
        cell.categoryImage.image = UIImage(named: categories[indexPath.row]["image"]!)
        
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        cell.layer.cornerRadius = 5
        
        return cell
        
    }
    
    //collectionView中有幾個item
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let categories = categories["categories"] else { return 0 }
        return categories.count
    }
    
    //MARK: - UICollectionViewDelegate
    //選取item後會呼叫
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categories = categories["categories"] else { return }
        let category = categories[indexPath.row]["name"]
        let categoryImage = categories[indexPath.row]["image"]
        
        record.item = category!
        record.image = categoryImage!
        selectedItemLabel.text = category!
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = #colorLiteral(red: 0.2121357918, green: 0.9065322876, blue: 0.6393124461, alpha: 0.4766160103)
        
        ItemRow = indexPath

        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    //MARK: - UITableViewDataSource
    //每列要顯示的時候呼叫
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DayRecordTableViewCell
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else { return cell }
        
        cell.timeLabel.text = String(records[indexPath.row]["time"]!)
        cell.categoryImage.image = UIImage(named: records[indexPath.row]["image"]!)
        cell.categoryName.text = String(records[indexPath.row]["item"]!)
        cell.amount.text = "$" + (Double(records[indexPath.row]["amount"]!)?.clean)!
        cell.locationLabel.text = records[indexPath.row]["location"]
        cell.annotationLabel.text = records[indexPath.row]["annotation"]
        
        cell.layer.cornerRadius = 10
        cell.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = days[section]
        guard let records = myRecords[date] else {
            return 0
        }
        
        return records.count
        
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return
        }
        print("records.count = \(records.count)")
        
        collectionView.allowsMultipleSelection = true
        
        myUserDefaults.set(Int(records[indexPath.row]["id"]!), forKey: "postID")
        myUserDefaults.set(nil, forKey: "isvalue")
        myUserDefaults.set(nil, forKey: "name")
        myUserDefaults.set(nil, forKey: "image")
        myUserDefaults.synchronize()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style:.default, title: "刪除") { (action,indexPath) in
            let date = self.days[indexPath.section]
            guard let records = self.myRecords[date] else {
                return
            }
            if let id = records[indexPath.row]["id"]{
                if let mydb = db {
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
                
            }
            self.updateAccountList()
            self.updateRecordsList()
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if isAddingNewRow && indexPath == IndexPath(row: 0, section: 0)  {
            cell.transform = CGAffineTransform(translationX: 1000, y: 0)
            
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.2,
                options: .curveEaseInOut,
                animations: {
                    cell.transform = CGAffineTransform.identity
                },
                completion: { _ in
                    self.isAddingNewRow = false
                }
            )
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier! {
            case "AnnotationSegue":
                let destinationController = segue.destination as! AnnotationViewController
                destinationController.viewController = self
            case "AccountSegue":
                let des = segue.destination as! AccountViewController
                des.viewController = self
            default:
                break
        }
    }
    
	//MARK: - update
    //更新列表
    func updateRecordsList() {
        let yearMonthDay = YMDformatter.string(from: currentDate)
        let yearMonth = YMformatter.string(from: currentDate)
        if let myDB = db {
            days = []
            myRecords = [:]
            
            var dayTotal:Double = 0
            var monthTotal:Double = 0
            
            let statement = myDB.fetch("records", column: nil, cond: "date == '\(yearMonthDay)'", order: " order by time desc, id desc")
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
                
                if date != "" {
                    if !days.contains(date) {
                        days.append(date)
                        myRecords[date] = []
                        print("days = \(days)")
                    }
                    myRecords[date]?.append([
                        "id":"\(id)",
                        "item":"\(item)",
                        "date":"\(date)",
                        "time":"\(time)",
                        "image":"\(image)",
                        "location":"\(location)",
                        "amount":"\(amount)",
                        "year":"\(year)",
                        "month":"\(month)",
                        "annotation":"\(annotation)"
                        ])
                    dayTotal += amount
                }
            }
            sqlite3_finalize(statement)
            //計算月花費
            let monthStatment = myDB.fetch("records", column: nil, cond: "date like '\(yearMonth)%'", order: nil)
            while sqlite3_step(monthStatment) == SQLITE_ROW {
                let amount = sqlite3_column_double(monthStatment, 6)
                monthTotal += amount
            }
            sqlite3_finalize(monthStatment)
            
            tableView.reloadData()
            dayAmount.text = "$" + dayTotal.clean
            monthAmount.text = "$" + monthTotal.clean
            
            let animation: CATransition = CATransition()
            animation.duration = 1.0
            animation.type = kCATransitionFade
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            dayAmount.layer.add(animation, forKey: "changeTextTransition")
            
        }
    }
    
    fileprivate func updateCategoryList() {
        categories["categories"] = []
        
        if let myDB = db {
            let statement = myDB.fetch("categories", column: nil, cond: nil, order: " order by id desc")
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let image = String(cString: sqlite3_column_text(statement, 1))
                let name = String(cString: sqlite3_column_text(statement, 2))
                categories["categories"]?.append([
                    "id":"\(id)",
                    "image":"\(image)",
                    "name":"\(name)"
                    ])
            }
            sqlite3_finalize(statement)
            collectionView.reloadData()
        }
    }
    
    func updateAccountList() {
        if let myDB = db,
			let acc = account {
            let statement = myDB.fetch("accounts", column: nil, cond: "id == \(acc.id)", order: " order by id desc")
            while sqlite3_step(statement) == SQLITE_ROW {
				account!.id = Int(sqlite3_column_int(statement, 0))
                accountNameLabel.text = String(cString: sqlite3_column_text(statement, 1))
				account!.balance = sqlite3_column_double(statement, 2)
				
				let accName = String(cString: sqlite3_column_text(statement, 1))
				if accName.count > 2 {
					let stringIndex = accName.index(accName.startIndex, offsetBy: 2)
					account!.title = accName.substring(to: stringIndex)
				} else {
					account!.title = accName
				}
			}
            sqlite3_finalize(statement)
            accountbutton.setTitle(account!.title, for: UIControlState.normal)
            acccountBalanceLabel.text = "$" + account!.balance.clean
		} else {
			emptyAccountSettings()
		}
    }
	
	func getDefaultAccount() {
		if let accName = myUserDefaults.object(forKey: "defaultAccountName") as? String {
			print("\(accName)......")
			acccountBalanceLabel.isHidden = false
			setAccount(accName: accName)
		} else {
			if let selectedAccountName = myUserDefaults.object(forKey: "userSelectedAccount") as? String {
				setAccount(accName: selectedAccountName)
			} else {
				emptyAccountSettings()
			}
			
		}
	}
	
	private func emptyAccountSettings(){
		account = nil
		accountbutton.setTitle("空", for: UIControlState.normal)
		accountNameLabel.text = "空帳戶"
		acccountBalanceLabel.isHidden = true
	}
	
	private func setAccount(accName: String) {
		if let myDB = db {
			let cond = "accountname = '\(accName)'"
			var defaultAccount = Account()
			let statment = myDB.fetch("accounts", column: nil, cond: cond, order: nil)
			while sqlite3_step(statment) == SQLITE_ROW {
				defaultAccount.id = Int(sqlite3_column_int(statment, 0))
				defaultAccount.title = String(cString: sqlite3_column_text(statment, 1))
				defaultAccount.balance = sqlite3_column_double(statment, 2)
				defaultAccount.initAmount = sqlite3_column_double(statment, 3)
			}
			self.account = defaultAccount
		}
	}
    
    //MARK: - Target Action
    //新增按鈕
    @IBAction func appendRecord(_ sender: UIButton) {
        isRecordSave = true
        now = Date()    //取得現在時間
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
            brain.performOperand("=")
            displayValue = brain.result
            descriptionLabel.text = brain.description

        if (record.item == "") {
            let alertController = UIAlertController(title: "提醒！", message: "請選擇類別", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            action.setValue(#colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1), forKey: "titleTextColor")
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        } else if (record.item != "" &&  Double(display.text!)! >= 0 && selectedItemLabel.text != "請選擇類別") {
            record.amount = Double(display.text!)!
            record.date = YMDformatter.string(from: currentDate)
            record.time = timeformater.string(from: now)
            record.item = selectedItemLabel.text!
            record.year = Yformatter.string(from: currentDate)
            record.month = Mformatter.string(from: currentDate)
            
            //更新帳戶餘額
			if let _ = account {
				account!.balance -= record.amount
			}
			
            
            //執行清除
            brain.performOperand("C")
            displayValue = brain.result
//            descriptionLabel.text = brain.description
            
            if let mydb = db {
                var rowInfo = [
                    "item":"'\(record.item)'",
                    "date":"'\(record.date)'",
                    "time":"'\(record.time)'",
                    "image":"'\(record.image)'",
                    "location":"'\(record.location)'",
                    "amount":"\(record.amount)",
                    "year":"'\(record.year)'",
                    "month":"'\(record.month)'",
                    "annotation":"'\(record.annotation)'"
                ]
				
				var accountInfo = [String: String]()
				if let _ = account {
					rowInfo["accountid"] = "\(account!.id)"
					accountInfo["balance"] = "\(account!.balance)"
					//更新帳戶金額
					_ = mydb.update("accounts", cond: "id == \(account!.id)", rowInfo: accountInfo)
				}
                
                //新增花費紀錄
                let success = mydb.insert("records", rowInfo:rowInfo )
                //新增成功記錄正在新增Row，以顯示動畫
                if success {
                    isAddingNewRow = true
                }

                //重整
                updateRecordsList()
                updateAccountList()
            }
            
            if collectionView.indexPathsForSelectedItems! != [] {
                if let ItemRow = ItemRow {
                    if let myDB = db {
                        guard let categories = categories["categories"] else {
                            return
                        }
                        print("categories = \(categories[ItemRow.row])")
                        let rowInfo = [
                            "name":"'\(categories[ItemRow.row]["name"]!)'",
                            "image":"'\(categories[ItemRow.row]["image"]!)'"
                        ]
                        let insertOk = myDB.insert("categories", rowInfo: rowInfo)
                        
                        if insertOk {
                                if let id = categories[ItemRow.row]["id"]{
                                print("id = \(id)")
                                _ = myDB.delete("categories", cond: "id = \(id)")
                            }
                        }
                        updateCategoryList()
                        
                    }
                    collectionView.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
                }
                ItemRow = nil
                record.annotation = ""
            }
            
            //新增的列顯示在最上
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.bottom, animated: true)

        }
        
    }
    
    @objc func selectTimeClick() {
        if YMDformatter.string(from: now) == YMDformatter.string(from: myDatePicker.date) {
            isTodayLabel.text = "今天"
            dateTextField.text = MDformatter.string(from: myDatePicker.date)
        } else {
            isTodayLabel.text = Yformatter.string(from: myDatePicker.date)
            dateTextField.text = MDformatter.string(from: myDatePicker.date)
            
        }
        updateCategoryList()
        currentDate = myDatePicker.date
        updateRecordsList()
        dateTextField.resignFirstResponder()
    }
    
    @objc func todayButtonClick() {
        currentDate = now
        isTodayLabel.text = "今天"
        myDatePicker.date = now
        dateTextField.text = MDformatter.string(from: myDatePicker.date)
        updateRecordsList()
        dateTextField.resignFirstResponder()
        
    }
    
    @objc func willEnterForeground() {
        updateAccountList()
        updateRecordsList()
        updateCategoryList()
//        updateViewConstraints()
		
    }

    //計算機
    @IBAction fileprivate func touchDigit(_ sender: UIButton) { //點擊0~9、小數點
        let digit = sender.currentTitle! //取數字鍵上的值
        if userIsInTheMiddleOfTyping { //如果有輸入過（不是第一次輸入）就進入
            let textCurrentlyInDisplay = display.text!
            if digit != DECIMAL_CHAR || display.text!.range(of: DECIMAL_CHAR) == nil { //輸入的不是小數點或display上沒有小數點
                if textCurrentlyInDisplay == "0" && digit == "0"{
                    display.text = "0"
                }else if textCurrentlyInDisplay == "0" && digit != "0" {
                     display.text = digit
                }else {
                    display.text = textCurrentlyInDisplay + digit   //
                }
            }
        } else {    //第一次按會執行這
            if digit == DECIMAL_CHAR { //如果是小數點
                display.text = "0\(digit)"
            } else {
                display.text = digit

            }
        }
        
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathOperation = sender.currentTitle {
            brain.performOperand(mathOperation)
        }
        displayValue =  brain.result

    }
    
    @IBAction func back(_ segue: UIStoryboardSegue) {
        
    }

}

