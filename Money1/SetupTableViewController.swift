//
//  SetupTableViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/18.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit
import CoreLocation

class SetupTableViewController: UITableViewController {
    
    let setupArr = ["定位","類別","帳戶","密碼","回饋意見"]
    let setupImage = ["location","category","account","password","email"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "設定"
        
        //tableView 外觀
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero) //消除多餘的分隔線
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = #colorLiteral(red: 0.9215686275, green: 0.9490196078, blue: 0.9176470588, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return setupArr.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SetupTableViewCell

        cell.setupLabel.text = setupArr[indexPath.section]
        cell.setupImage.image = UIImage(named: setupImage[indexPath.section])
        
        if indexPath.section == 0 && indexPath.row == 0 {
            if ((CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)
                && CLLocationManager.locationServicesEnabled()){
                cell.accessoryType = .checkmark
                cell.tintColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1)
            } else {
                cell.accessoryType = .none
            }
        }
        
        if indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3  {
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SetupCategoryTableViewController
        
        switch segue.identifier! {
        case "SetupCategory":
            vc.categoryToSet = .setItem
        case "SetupAccount":
            vc.categoryToSet = .setAccount
		case "SetupPassword":
			vc.categoryToSet = .setPassword
        default:
            break
        }
    }
 

    //MARK - Table view delegate
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 3 {
//            return "ruru7947@gmail.com"
//        }
//        return ""
//    }
    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        guard let header = view as? UITableViewHeaderFooterView else { return }
//        header.textLabel?.textColor = UIColor.lightGray
//        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 8)
//        header.textLabel?.frame = header.frame
//        header.textLabel?.textAlignment = .center
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
                let settingUrl = URL(string: "App-Prefs:root=com.ruru.money")!
                if UIApplication.shared.canOpenURL(settingUrl)
                {
                    UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                }
        }
        
        if indexPath.section == 1 {
            performSegue(withIdentifier: "SetupCategory", sender: nil)
        }
        
        if indexPath.section == 2 {
            performSegue(withIdentifier: "SetupAccount", sender: nil)
        }
		
		if indexPath.section == 3 {
			performSegue(withIdentifier: "SetupPassword", sender: nil)
		}
        
        if indexPath.section == 4 {
            let email = "ruru7947@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    @objc func willEnterForeground() {
        tableView.reloadData()
    }
    
}
