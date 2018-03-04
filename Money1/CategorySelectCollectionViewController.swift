//
//  CategorySelectCollectionViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/6.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CategorySelectCollectionViewController: UICollectionViewController {
    
    var categories:[String:[[String:String]]]! = [:]
    let myUserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        updateCategoryList()
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let categories = categories["categories"] else {return 0}
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategorySelectCollectionViewCell
        guard let categories = categories["categories"] else {return cell}
        
        cell.categoryLabel.text = String(categories[indexPath.row]["name"]!)
        cell.categoryImageView.image = UIImage(named: categories[indexPath.row]["image"]!)
        
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categories = categories["categories"] else {return}
        
        myUserDefaults.set(categories[indexPath.row]["name"], forKey: "name")
        myUserDefaults.set(categories[indexPath.row]["image"], forKey: "image")
        myUserDefaults.synchronize()

        self.navigationController?.popViewController(animated: true)
    }

    func updateCategoryList() {
        categories["categories"] = []
        
        if let myDB = db {
            let statement = myDB.fetch("categories", column: "*", cond: nil, order: "order by id desc")
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
            collectionView?.reloadData()
        }
    }

}
