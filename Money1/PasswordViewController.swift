//
//  PasswordViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 26/02/2018.
//  Copyright © 2018 ruru. All rights reserved.
//

import UIKit

struct KeychainConfiguration {
	static let serviceName = "TouchMeIn"
	static let username = "user"
	static let accessGroup: String? = nil
}

class PasswordViewController: UIViewController {
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var sixDotsStackView: UIStackView!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var infoLabel: UILabel!
	
	var passwordOption: PasswordOption = .verifyPassword
	
	private var numberofWordsTyping: Int = 0
	private let	numberOfPasswordWords = 4
	private var isUpdating = false
	private var verifyFaild = false

	
    override func viewDidLoad() {
        super.viewDidLoad()
		passwordTextField.delegate = self
		
		updateInfoLabel()
		
		passwordTextField.isHidden = true
		passwordTextField.keyboardType = .numberPad
		passwordTextField.becomeFirstResponder()
		
		passwordTextField.addTarget(self, action: #selector(typing(sender:)), for: UIControlEvents.editingChanged)
		
		dots()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func loginAction() {
		guard let newPassWord = passwordTextField.text else {
			infoLabel.text = "輸入密碼"
			return
		}

		switch passwordOption {
		case .setPassword:
			do {
				let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
														account: KeychainConfiguration.username,
														accessGroup: KeychainConfiguration.accessGroup)
				try passwordItem.savePassword(newPassWord)
			} catch {
				fatalError("Error update KeyChain")
			}
			myUserDefaults.set(true, forKey: "hasPassword")
			passwordTextField.resignFirstResponder()
			dismissPage()
			
		case .turnOffPassword:
			if checkLogin(userName: KeychainConfiguration.username, password: newPassWord) {
				do {
					let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
															account: KeychainConfiguration.username,
															accessGroup: KeychainConfiguration.accessGroup)
					try passwordItem.deleteItem()
					print("真奇怪")
					myUserDefaults.set(false, forKey: "hasPassword")
					passwordTextField.resignFirstResponder()
					dismissPage()
				} catch {
					fatalError("關閉失敗")
				}
				
			} else {
				verifyFaild = true
				updateInfoLabel()
				resetDots()
			}
		case .updatePassword:
			isUpdating = true
			if checkLogin(userName: KeychainConfiguration.username, password: newPassWord) {
				passwordOption = .setPassword
				verifyFaild = false
				updateInfoLabel()
				resetDots()
			} else {
				verifyFaild = true
				resetDots()
				updateInfoLabel()
			}
		case .verifyPassword:
			if checkLogin(userName: KeychainConfiguration.username, password: newPassWord) {
				dismissPage()
			} else {
				verifyFaild = true
				updateInfoLabel()
				resetDots()
			}
		}
		
	}
	
	private func dots() {
		for index in 0...3 {
			let view = sixDotsStackView.arrangedSubviews[index]
			view.layer.cornerRadius = 5
			view.layer.borderColor = #colorLiteral(red: 0.1488042332, green: 0.7418900698, blue: 0.4107980761, alpha: 1)
			view.layer.borderWidth = 1
			view.clipsToBounds = true
		}
	}
	
	private func updateInfoLabel() {
		switch passwordOption {
		case .setPassword:
			if isFirstTime {
				infoLabel.text = isUpdating ? "輸入新密碼" : "輸入密碼"
			} else {
				infoLabel.text = verifyFaild ? "密碼不匹配，重新設定密碼" : "驗證密碼"
			}
			title = "設定密碼"
		case .turnOffPassword:
			infoLabel.text = verifyFaild ? "密碼不匹配，再輸入一次" : "輸入密碼"
			title = "關閉密碼"
		case .updatePassword:
			infoLabel.text = verifyFaild ? "密碼不匹配，再輸入一次舊密碼" : "請輸入舊密碼"
			title = "更改密碼"
		case .verifyPassword:
			infoLabel.text = verifyFaild ? "錯誤，再輸入一次" : "輸入密碼"
			navigationController?.navigationBar.isHidden = true
		}
	}
	
	private func updateDots(at index: Int, isTyping: Bool) {
		let view = sixDotsStackView.arrangedSubviews[index]
		view.backgroundColor = isTyping ? #colorLiteral(red: 0.1488042332, green: 0.7418900698, blue: 0.4107980761, alpha: 1) : #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
	}
	
	func numberOfWordsEntered(textField: UITextField) -> Int {
		let currentCount = textField.text!.count
		if currentCount > numberofWordsTyping {
			let index = currentCount - 1
			updateDots(at: index, isTyping: true)
		} else {
			let index = numberofWordsTyping - 1
			updateDots(at: index, isTyping: false)
		}
		numberofWordsTyping = currentCount
		return currentCount
	}
	
	private func resetDots() {
		let views = sixDotsStackView.arrangedSubviews
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			for view in views {
				view.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
			}
			self.numberofWordsTyping = 0
			self.passwordTextField.text = ""
		}
		
	}
	
	private var checkPassword: String = ""
	private var isFirstTime: Bool = true
	
	@objc func typing(sender: UITextField) {
		let numOfPassword = numberOfWordsEntered(textField: sender)
		if numOfPassword == 4 {
			switch passwordOption {
			case .setPassword:
				if isFirstTime {
					isFirstTime = false
					verifyFaild = false
					checkPassword = sender.text!
					updateInfoLabel()
					resetDots()
				} else if checkPassword == sender.text! {
					loginAction()
				} else {
					verifyFaild = true
					updateInfoLabel()
					resetDots()
					isFirstTime = true //重新設定所以設為true
				}
			case .turnOffPassword, .updatePassword, .verifyPassword:
				loginAction()
				
			}
		}
	}
	
	private func dismissPage() {
		myUserDefaults.synchronize()
		passwordTextField.resignFirstResponder()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			self.dismiss(animated: true, completion: nil)
		}
		
	}
	
	func checkLogin(userName: String, password: String) -> Bool {
		do {
			let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
													account: userName,
													accessGroup: KeychainConfiguration.accessGroup)
			let keychainPassword = try passwordItem.readPassword()
			return password == keychainPassword
		} catch {
			fatalError("Error readind password from keychain - \(error)")
		}
		
	}
	
	
	@IBAction func cancelButtonClick(_ sender: Any) {
		dismissPage()
	}
	
	deinit {
		print("PasswordViewController deinit")
	}
	
}

extension PasswordViewController: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let maxLenght = 4
		let currentString: NSString = textField.text! as NSString
		let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
		print("newString = \(newString)")
		return newString.length <= maxLenght
	}
	
}
