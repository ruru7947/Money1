
import UIKit

class editRecordViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var dateTextField: myUITextField!
    @IBOutlet weak var timeTextField: myUITextField!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var locationTextField: myUITextField!
    @IBOutlet weak var annotationTextField: myUITextField!
    
    var record = Record()
    let myUserDefaults = UserDefaults.standard
    var dateDatePicker :UIDatePicker!
    var timeDatePicker :UIDatePicker!
    var toolBar: UIToolbar! = nil
    let YMDFormatter = DateFormatter()//年月日
    let timeFormatter = DateFormatter() //時間

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "修改"
        
        locationTextField.returnKeyType = .done
        locationTextField.tag = 1
        annotationTextField.returnKeyType = .done
        annotationTextField.tag = 2
        
        let recordId = myUserDefaults.object(forKey: "postID") as! Int //紀錄上一頁選擇紀錄的Id
        let dbFileName = myUserDefaults.object(forKey: "dbFileName") as! String
        
        //重資料庫抓資料
        db = SQLiteConnect(file: dbFileName)
        if let mydb = db {
            let statement = mydb.fetch("records", column: nil, cond: "id == \(recordId)", order: nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                print("抓到資料了")
                record.id = Int(sqlite3_column_int(statement, 0))
                record.item = String(cString: sqlite3_column_text(statement, 1))
                record.date = String(cString: sqlite3_column_text(statement, 2))
                record.time = String(cString: sqlite3_column_text(statement, 3))
                record.image = String(cString: sqlite3_column_text(statement, 4))
                record.location = String(cString: sqlite3_column_text(statement, 5))
                record.amount = sqlite3_column_double(statement, 6)
                record.annotation = String(cString: sqlite3_column_text(statement, 9))
                record.accountID = Int(sqlite3_column_int(statement, 10))
            }
            sqlite3_finalize(statement)
        }
        
        //格式化日期字串.,m
        YMDFormatter.dateFormat = "YY-MM-dd"
        timeFormatter.dateFormat = "HH:mm"
        
        //ToolBar
        let ToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let cancelButton = UIBarButtonItem.init(title: "取消", style: .done, target:self, action: #selector(cancel))
        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem.init(title: "確定", style: .done, target: self, action: #selector(done))
        doneButton.tintColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1)
        cancelButton.tintColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1)
        ToolBar.setItems([cancelButton, space, doneButton], animated: true) //加上按鈕
        
        //timeDatePicker
        timeDatePicker = UIDatePicker() //實體化
        timeDatePicker.locale = Locale(identifier: "zh_TW") //時區，台灣
        timeDatePicker.datePickerMode = .time //設定時間選擇器的模式
        timeDatePicker.backgroundColor = UIColor.white
        timeDatePicker.setValue(#colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1), forKey: "textColor")
        timeDatePicker.date = timeFormatter.date(from: record.time)!
        
        
        timeTextField.inputView = timeDatePicker
        timeTextField.inputAccessoryView = ToolBar
        
        
        //dateDatePicker
        dateDatePicker = UIDatePicker() //實體化
        dateDatePicker.locale = Locale(identifier: "zh_TW") //時區，台灣
        dateDatePicker.datePickerMode = .date //設定時間選擇器的模式
        dateDatePicker.backgroundColor = UIColor.white
        dateDatePicker.setValue(#colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1), forKey: "textColor")
        dateDatePicker.date = YMDFormatter.date(from: record.date)!
        
        dateTextField.inputView = dateDatePicker
        dateTextField.inputAccessoryView = ToolBar

        amountTextField.inputAccessoryView = ToolBar
        amountTextField.clearsOnInsertion = true
        //顯示點選的cell的內容
        dateTextField.text = record.date
        timeTextField.text = record.time
        categoryLabel.text = record.item
        categoryImage.image = UIImage(named: record.image)
        locationTextField.text = record.location
        annotationTextField.text = record.annotation
        amountTextField.text = record.amount.clean
		
//		let views = view.subviews.filter { (view) -> Bool in
//			let v = view as? UITextField
//			return v != nil
//		}
//		let lowestTextField = views.sorted { (view1, view2) -> Bool in
//			return view1.frame.maxY > view2.frame.maxY
//		}
		
    }
    
    func datePickerFunc(locale: Locale, datePickerMode: UIDatePickerMode, backgroundColor:UIColor, color: UIColor) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.locale = locale
        datePicker.datePickerMode = datePickerMode
        datePicker.backgroundColor = backgroundColor
        datePicker.setValue(color, forKey: "textColor")
        
        return datePicker
    }
    
    
    
    //自製func
    
    @objc func done() {
        
        if dateTextField.isFirstResponder {
            record.date = YMDFormatter.string(from: dateDatePicker.date)
            dateTextField.text = record.date
            dateTextField.resignFirstResponder()
        }
        if  timeTextField.isFirstResponder {
            record.time = timeFormatter.string(from: timeDatePicker.date)
            timeTextField.text = record.time
            timeTextField.resignFirstResponder()
        }
        
        if amountTextField.isFirstResponder {
            if amountTextField.text == "" {
                amountTextField.text = record.amount.clean
            }
            
            if amountTextField.text != ""{
                if let amount = Double(amountTextField.text!) {
                    let amountDiff = amount - record.amount
                    record.amount += amountDiff
                    updateAccountBalance(update: amountDiff != 0, amountDiff: amountDiff)
                }else{
                    print("你沒這麼多錢")
                    amountTextField.text = record.amount.clean
                }
                
            }
            
            amountTextField.resignFirstResponder()
            
        }
        

    }
    
    @objc func cancel(){
        
        if amountTextField.isFirstResponder {
            amountTextField.text = record.amount.clean
        }
        
         dateTextField.resignFirstResponder()
         timeTextField.resignFirstResponder()
         amountTextField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //隱藏tabBar
        self.tabBarController?.tabBar.isHidden = true
        
        guard let name = myUserDefaults.string(forKey: "name"),
            let image = myUserDefaults.string(forKey: "image") else {
            return
        }
        record.item = name
        record.image = image
        
        categoryLabel.text = record.item
        categoryImage.image = UIImage(named: record.image)
        print(record.item)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1{
            //if locationTextField.text == "" {
                //locationTextField.text = record.location
            //}
            record.location = locationTextField.text!
            print(record.location)
        } else if textField.tag == 2 {
            //if annotationTextField.text == "" {
                //annotationTextField.text = record.annotation
            //}
            record.annotation = annotationTextField.text!
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Target Action
    @IBAction func update(_ sender: FancyButton) {
        if let mydb = db {
            let rowInfo = [
                "item":"'\(record.item)'",
                "date":"'\(record.date)'",
                "time":"'\(record.time)'",
                "image":"'\(record.image)'",
                "location":"'\(record.location)'",
                "amount":"\(record.amount)",
                "annotation":"'\(record.annotation)'"
            ]
            var updateAccess:Bool
            updateAccess = mydb.update("records", cond: "id = \(record.id)", rowInfo:rowInfo)
            
            if updateAccess {
                print("更新成功")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateAccountBalance(update: Bool, amountDiff: Double) {
        var accBalance: Double = 0
        if let mydb = db {
            let statement = mydb.fetch("accounts", column: nil, cond: "id == \(record.accountID)", order: nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                accBalance = sqlite3_column_double(statement, 2) - amountDiff
            }
            sqlite3_finalize(statement)
            
            let rowInfo = ["balance": "\(accBalance)"]
            _ = mydb.update("accounts", cond: "id = \(record.accountID)", rowInfo:rowInfo)
        }
    }

}
