//
//  SetupAccountViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 28/02/2018.
//  Copyright © 2018 ruru. All rights reserved.
//

import UIKit


class SetupAccountViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var footerView: UIView!
	@IBOutlet weak var defaultDtateView: UIStackView!
	@IBOutlet weak var defultSwitch: UISwitch!
	
	
	var isCreatAccount:Bool = true
	let setAccountItem = ["帳戶名稱", "起始金額"]
	var account: Account?
	
	weak var nametextField: UITextField!
	weak var initAmountTextField: UITextField!
	
	var defaultStatus: Bool!
	
//	var isCreatAccount: Bool!

	@IBOutlet weak var updateAndCreatButton: FancyButton!
	@IBOutlet weak var deleteButton: FancyButton!

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.dataSource = self
		
		UpdateText()
		checkAccountDefaultStatus()
		
		//tableView 外觀
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		tableView.tableFooterView = UIView(frame: CGRect.zero) //消除多餘的分隔線
		tableView.separatorStyle = .singleLine
		tableView.separatorColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
		tableView.contentInset.top = CGFloat(8)
		tableView.isScrollEnabled = false
		tableView.tableFooterView = footerView

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func updateAndCreat(_ sender: Any) {
		if isCreatAccount {
			creatAccount()
		} else {
			updateAccountInfo()
		}
		
	}
	
	@IBAction func deleteAction(_ sender: Any) {
		self.textFieldResignFirstResponder()
		let controller = UIAlertController(title: "刪除帳戶", message: "確定要刪除嗎", preferredStyle: .alert)
		let action = UIAlertAction(title: "刪除", style: .default) { (action) in
			guard let id = self.account?.id else {
				return
			}
			
			self.deleteAccount(accountId: id)
		}
		let deleteAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
		controller.addAction(action)
		controller.addAction(deleteAction)
		present(controller, animated: true, completion: nil)
	}
	
	private func UpdateText() {
		updateAndCreatButton.setTitle(isCreatAccount ? "新增" : "更新", for: .normal)
		deleteButton.isHidden = isCreatAccount
		title = isCreatAccount ? "新增帳戶" : "更新帳戶-\(account!.title)"
	}
	
	private func textFieldResignFirstResponder() {
		nametextField.resignFirstResponder()
		initAmountTextField.resignFirstResponder()
	}
	
	private func setDefaultAccount(setNil: Bool) {
		if defaultStatus == true && !defultSwitch.isOn {
			print("本來是改不是")
			myUserDefaults.set(nil, forKey: "defaultAccountName")
		} else if defultSwitch.isOn == true {
			if setNil {
				myUserDefaults.set(nil, forKey: "defaultAccountName")
			} else {
				myUserDefaults.set(nametextField.text, forKey: "defaultAccountName")
			}
		}
	}
	
	private func checkAccountDefaultStatus() {
		if isCreatAccount {
			defultSwitch.isOn = false
			defaultStatus = false
		} else {
			if let title = account?.title {
				let status = title == myUserDefaults.string(forKey: "defaultAccountName")
				defultSwitch.isOn = status
				defaultStatus = status
			}
		}
	}
	
	
	private func updateAccountInfo() {
		guard let id = account?.id, let accName = nametextField.text,
			var initAmount = Double(initAmountTextField.text!) else {
				let controller = UIAlertController(title: isCreatAccount ? "新增" : "更新", message: "請輸入完整資訊", preferredStyle: .alert)
				let action = UIAlertAction(title: "確定", style: .cancel, handler: nil)
				controller.addAction(action)
				present(controller, animated: true, completion: nil)
				return
		}
		
		let max:Double = 1000000000000
		if var account = account {
			initAmount = initAmount > max ? max : initAmount
			let difference =  initAmount - account.initAmount
			account.balance += difference
			let cond = "id == \(id)"
			let rowInfo = [
				"accountname": "'\(accName)'",
				"balance": "\(account.balance)",
				"initAmount": "\(initAmount)"
			]
			let success = db.update("accounts", cond: cond, rowInfo: rowInfo)
			if success {
				setDefaultAccount(setNil: false)
				textFieldResignFirstResponder()
				self.navigationController?.popViewController(animated: true)
				print("更新成功")
			}
		}
		
	}
	
	private func creatAccount() {
		guard let accName = nametextField.text,
			var initAmount = Double(initAmountTextField.text!) else {
				return
		}
		
		let max: Double = 1000000000000
		initAmount = initAmount > max ? max : initAmount
		let rowInfo = [
			"accountname":"'\(accName)'",
			"balance":"\(initAmount)",
			"initAmount":"\(initAmount)"
		]
		
		let success = db.insert("accounts", rowInfo: rowInfo)
		if success {
			setDefaultAccount(setNil: false)
			textFieldResignFirstResponder()
			self.navigationController?.popViewController(animated: true)
			print("新增成功")
		}
	}
	
	private func deleteAccount(accountId: Int) {
		let cond = "id == \(accountId)"
		let deleteSuccess = db.delete("accounts", cond: cond)
		if deleteSuccess {
			setDefaultAccount(setNil: true)
			textFieldResignFirstResponder()
			self.navigationController?.popViewController(animated: true)
			print("刪除成功")
		}
	}
	
	deinit {
		print("SetupAccountViewController deinit")
	}

}

extension SetupAccountViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return setAccountItem.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SetupAccountTableViewCell
	
		cell.nameLabel.text = setAccountItem[indexPath.row]
		if isCreatAccount {
			cell.textField.text = indexPath.row == 0 ? "" : 0.0.clean
		} else {
			cell.textField.text = indexPath.row == 0 ? account?.title : account?.initAmount.clean
		}
		
		if indexPath.row == 0 {
			cell.textField.returnKeyType = .done
			nametextField = cell.textField
			nametextField.becomeFirstResponder()
		} else if indexPath.row == 1 {
			cell.textField.keyboardType = .numberPad
			initAmountTextField = cell.textField
			initAmountTextField.clearsOnInsertion = true
		}
		
		return cell
	}
}
