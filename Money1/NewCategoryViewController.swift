//
//  NewCategoryViewController.swift
//  Money1
//
//  Created by 梁宏儒 on 2017/8/19.
//  Copyright © 2017年 ruru. All rights reserved.
//

import UIKit

class NewCategoryViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var addTitleButton: FancyButton!
    
    var categoryImageArr = [String]()
    var setupName:String!
    var setupImage:String!
    var setupid:String!
    var selectImageName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "新增類別"
        
        categoryNameTextField.delegate = self
        categoryNameTextField.returnKeyType = .done
        
        categoryImageArr = ["bus","clock","donations","donations2","drink","drink2","exercise","exercise2","exercise3","food","food2","gas","gas2","happy","happy2","house","house2","pet","pet2","pet3","taxi","travel","travel2","phone","mac","park","doctor","medical","gift","gift2","house3","cosmetics","cosmetics2","food3","clothing","clothing2","book3","book2"]
        
        setupName = myUserDefaults.string(forKey: "setupname")
        setupImage = myUserDefaults.string(forKey: "setupimage")
        setupid = myUserDefaults.string(forKey: "setupid")
        selectImageName = setupImage
        
        if setupName != nil && setupImage != nil {
            title = "修改類別-" + setupName!
            categoryNameTextField.text = setupName
            selectImage.image = UIImage(named:setupImage!)
            addTitleButton.setTitle("修改", for: UIControlState.normal)
        } else {
            categoryNameTextField.placeholder = "請輸入類別"
            addTitleButton.setTitle("新增", for: UIControlState.normal)
        }
    }
    
    @IBAction func newButton(_ sender: UIButton) {
        categoryNameTextField.resignFirstResponder()
        if let myDB = db {
            if setupid != nil {
                if categoryNameTextField.text != "" {
                    let image = selectImageName ?? setupImage
                    let rowInfo = [
                        "image":"'\(image!)'",
                        "name":"'\(categoryNameTextField.text!)'"
                    ]
                    _ = myDB.update("categories", cond: "id = \(setupid!)", rowInfo: rowInfo)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("...")
                    let alert = UIAlertController(title: "提示", message: "選擇圖片，輸入類別", preferredStyle: UIAlertControllerStyle.alert)
                    present(alert, animated: true, completion: {sleep(1)})
                    alert.dismiss(animated: true, completion: nil)
                }
            } else {
                guard let image = selectImageName,
                    let name = categoryNameTextField.text else {
                        let alert = UIAlertController(title: "提示", message: "選擇圖片，數入類別", preferredStyle: UIAlertControllerStyle.alert)
                        present(alert, animated: true, completion: {sleep(1)})
                        alert.dismiss(animated: true, completion: nil)
                        return
                }
                let rowInfo = [
                    "image":"'\(image)'",
                    "name":"'\(name)'"
                ]
                _ = myDB.insert("categories", rowInfo: rowInfo)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
     //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryImageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! NewCategoryCollectionViewCell
        
        item.categoryImage.image = UIImage(named: categoryImageArr[indexPath.row])
        
        return item
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectImage.image = UIImage(named: categoryImageArr[indexPath.row])
        selectImageName = categoryImageArr[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = #colorLiteral(red: 0.03921568627, green: 0.7411764706, blue: 0.6274509804, alpha: 1)
        cell?.isHighlighted = true
        
        categoryNameTextField.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
