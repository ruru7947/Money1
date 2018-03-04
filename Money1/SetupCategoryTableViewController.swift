//
//  SetupCategoryTableViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/18.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

protocol SetupAccountDelegate {
	func loadInfo(isAddAccount: Bool)
}

class SetupCategoryTableViewController: UITableViewController {
    
    var categories:[String:[[String:String]]]! = [:]
    var accounts: [Account]!
	var passwordOPtions: [String]! = ["關閉密碼", "更新密碼"]
	
	@IBOutlet weak var headerView: UIView!
	
	let space: CGFloat = 45
    
    var categoryToSet: CategoryToSet!
	var isAddAccount: Bool!
	
	var selectedAccount: Account?
	
	private var goToUpdatePassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView 外觀
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero) //消除多餘的分隔線
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch categoryToSet {
        case .setItem:
            updateCategoryList()
			hiddenHeaderView(needed: false)
        case .setAccount:
            fetchAccountList()
			hiddenHeaderView(needed: false)
		case .setPassword:
			fetchAccountList()
			hiddenHeaderView(needed: true)
			update()
			tableView.reloadData()
        default:
            break
        }
    }
	
	private func update() {
		passwordOPtions[0] = myUserDefaults.bool(forKey: "hasPassword") ? "關閉密碼" : "開啟密碼"
	}
	
	private func hiddenHeaderView(needed: Bool) {
		headerView.isHidden = needed
		let headerViewHeight = -(headerView.frame.height) + space
		tableView.contentInset = UIEdgeInsets(top: needed ? headerViewHeight : 0, left: 0, bottom: 0, right: 0)
	}
    
    @IBAction func addButton(_ sender: Any) {
        switch categoryToSet {
        case .setItem:
            myUserDefaults.set(nil, forKey: "setupname")
            myUserDefaults.set(nil, forKey: "setupimage")
            myUserDefaults.set(nil, forKey: "setupid")
            performSegue(withIdentifier: "NewCategory", sender: nil)
        case .setAccount:
			isAddAccount = true
			selectedAccount = nil
			performSegue(withIdentifier: "GoToSetupAccount", sender: nil)
        default:
            break
        }
        
    }
    
    
    func updateCategoryList() {
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
            tableView.reloadData()
        }
    }
    
    func fetchAccountList() {
        accounts = []
        if let myDB = db {
            let statement = myDB.fetch("accounts", column: nil, cond: nil, order: " order by id desc")
            while sqlite3_step(statement) == SQLITE_ROW {
				let id = Int(sqlite3_column_int(statement, 0))
                let accountName = String(cString: sqlite3_column_text(statement, 1))
                let balance = sqlite3_column_double(statement, 2)
				let initAmount = sqlite3_column_double(statement, 3)
				let account = Account(id: id, title: accountName, balance: balance, initAmount: initAmount)
                accounts?.append(account)
            }
            sqlite3_finalize(statement)
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch categoryToSet {
        case .setItem:
            guard let categories = categories["categories"] else { return 0 }
            return categories.count
        case .setAccount:
            guard let accounts = accounts else { return 0 }
            return accounts.count
		case .setPassword:
			return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SetupCategoryTableViewCell
        
        switch categoryToSet {
        case .setItem:
            guard let categories = categories["categories"] else { return cell }
            cell.categoryToSet = .setItem
            cell.name.text = String(categories[indexPath.row]["name"]!)
            cell.categoryImage.image = UIImage(named: categories[indexPath.row]["image"]!)
            return cell
            
        case .setAccount:
            guard let accounts = accounts else { return cell }
            cell.categoryToSet = .setAccount
            cell.name.text = accounts[indexPath.row].title
			cell.balanceLabel.text = "$" + accounts[indexPath.row].balance.clean
            return cell
			
		case .setPassword:
			update()
			cell.accessoryType = .none
			cell.categoryToSet = .setPassword
			cell.name.text = passwordOPtions[indexPath.row]
			return cell
            
        default:
            return cell
        }
    }
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if categoryToSet == .setItem {
			return true
		}
		return false
	}
	
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "SetPasswordSegue" {
			let nav = segue.destination as! UINavigationController
			let vc = nav.viewControllers[0] as! PasswordViewController
			if goToUpdatePassword {
				vc.passwordOption = .updatePassword
			} else {
				vc.passwordOption = myUserDefaults.bool(forKey: "hasPassword") ? .turnOffPassword : .setPassword
			}
		}
		
		if segue.identifier == "GoToSetupAccount" {
			let vc = segue.destination as! SetupAccountViewController
			vc.isCreatAccount = isAddAccount
			vc.account = selectedAccount
		}
    }

    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch categoryToSet {
		case .setItem:
			guard let categories = categories["categories"] else {
				return
			}
			
			myUserDefaults.set(categories[indexPath.row]["name"], forKey: "setupname")
			myUserDefaults.set(categories[indexPath.row]["image"], forKey: "setupimage")
			myUserDefaults.set(categories[indexPath.row]["id"], forKey: "setupid")
			performSegue(withIdentifier: "NewCategory", sender: nil)
			
		case .setAccount:
			isAddAccount = false
			selectedAccount = accounts[indexPath.row]
			performSegue(withIdentifier: "GoToSetupAccount", sender: self)
			
		case .setPassword:
			if indexPath.row == 0 {
				goToUpdatePassword = false
			}
			if indexPath.row == 1 {
				goToUpdatePassword = true
			}
			performSegue(withIdentifier: "SetPasswordSegue", sender: self)
		default:
			break
		}
	
    }
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		switch categoryToSet {
		case .setPassword:
			if myUserDefaults.bool(forKey: "hasPassword") && indexPath.row == 1 {
				return IndexPath(row: 1, section: 0)
			} else if indexPath.row == 1 && !myUserDefaults.bool(forKey: "hasPassword") {
				return nil
			}
			return indexPath
		default:
			return indexPath
		}
		
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if categoryToSet == .setPassword {
			if indexPath.row == 1 && !myUserDefaults.bool(forKey: "hasPassword") {
				cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
				cell.isUserInteractionEnabled = false
			} else if indexPath.row == 1 && myUserDefaults.bool(forKey: "hasPassword") {
				cell.backgroundColor = #colorLiteral(red: 0.8797520995, green: 0.9081843495, blue: 0.8798796535, alpha: 1)
				cell.isUserInteractionEnabled = true
			}
		}
		
	}
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		switch categoryToSet {
		case .setItem:
			let rowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "刪除") { (action, indexpath) in
				guard let categories = self.categories["categories"] else {
					return
				}
				if let id = categories[indexPath.row]["id"],
					let myDB = db {
					_ = myDB.delete("categories", cond: "id = \(id)")
					self.updateCategoryList()
				}
			}
			return [rowAction]

		default:
			return nil
		}
		
    }
	
}
