//
//  AccountViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/29.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var accountCollectionView: UICollectionView!
    
    var accounts:[String:[[String:String]]]! = [:]
    
    weak var viewController: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
		accountCollectionView.backgroundColor = UIColor.clear
		accountCollectionView.layer.cornerRadius = 15
		accountCollectionView.layer.borderColor = UIColor.white.cgColor
		accountCollectionView.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateAccountList()
    }

    fileprivate func updateAccountList() {
        accounts["accounts"] = []
        if let myDB = db {
            let statement = myDB.fetch("accounts", column: nil, cond: nil, order: " order by id desc")
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let accountName = String(cString: sqlite3_column_text(statement, 1))
                let balance = sqlite3_column_double(statement, 2)
				let initAmount = sqlite3_column_double(statement, 3)
                accounts["accounts"]?.append([
                    "id":"\(id)",
                    "accountName":"\(accountName)",
                    "accountBalance":"\(balance)",
					"accountInitAmount":"\(initAmount)"
                    ])
            }
            sqlite3_finalize(statement)
            accountCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let accounts = accounts["accounts"] else { return 0 }
        return accounts.count
   
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AccountCollectionViewCell
        guard let accounts = accounts["accounts"] else { return cell }
        
        cell.accountNameLabel.text = accounts[indexPath.row]["accountName"]
        cell.accountBalanceLabel.text = "$" + (Double(accounts[indexPath.row]["accountBalance"]!)?.clean)!
        
        cell.layer.cornerRadius = 15
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let accounts = accounts["accounts"] else { return }
		
        let name = accounts[indexPath.row]["accountName"]!
        let accountId = Int(accounts[indexPath.row]["id"]!)!
		let accountBalance = Double(accounts[indexPath.row]["accountBalance"]!)!
		let accountInitAmount = Double(accounts[indexPath.row]["accountInitAmount"]!)!
		
		var SelectedAccount = Account()
		let range: Range<String.Index>
		if name.count > 2 {
			range = name.index(name.endIndex, offsetBy: 2 - name.count)..<name.endIndex
			SelectedAccount.title = String(name[range])
		} else {
			SelectedAccount.title = name
		}
        SelectedAccount.id = accountId
		SelectedAccount.balance = accountBalance
		SelectedAccount.initAmount = accountInitAmount
		viewController.account = SelectedAccount
		
		viewController.acccountBalanceLabel.isHidden = false
        viewController.updateAccountList()
		
		myUserDefaults.set(name, forKey: "userSelectedAccount") //儲存使用者選擇的帳戶(非預設帳戶)，在使用者沒有設定預設帳戶的情況下
    }
	
	@IBAction func emptyAccount(_ sender: Any) {
		viewController.account = nil
		myUserDefaults.set("emptyAccount", forKey: "userSelectedAccount")
		viewController.updateAccountList()
		dismiss(animated: true, completion: nil)
	}
	
    

}
