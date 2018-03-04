//
//  SQLiteConnect.swift
//  Money
//
//  Created by joe feng on 2016/6/21.
//  Copyright © 2016年 hsin. All rights reserved.
//

import Foundation

class SQLiteConnect {
    
    var db :OpaquePointer? = nil    //儲存 SQLite 的連線資訊
    let sqlitePath :String
    
    init?(file :String) {
        // 資料庫檔案的路徑，開發者儲存檔案的路徑，有任何需要儲存的檔案都是放在這裡
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //sqlite3.db是這個資料庫檔案名稱，如果沒有這個檔案，系統會自動建立
        //urls[urls.count-1]是為了得到第一個元素（元素位置是0），absoluteString會回傳一個字串
        sqlitePath = urls[urls.count-1].absoluteString + file
        db = self.openDatabase(sqlitePath) //將執行sqlite3_open得到的連線資訊指定給db，接下來就可以用db來操作資料庫
        if db == nil {
            return nil
        }

    }
    
    // 連結資料庫 connect database
    func openDatabase(_ path :String) -> OpaquePointer? {
        var connectdb: OpaquePointer? = nil
        //使用sqlite3_open()函式來連線，連線成功會回傳SQLITE_OK
        if sqlite3_open(path, &connectdb) == SQLITE_OK {
            print("Successfully opened database \(path)")
            return connectdb!
        } else {
            print("Unable to open database.")
            return nil
        }
    }
    
    // 建立資料表 create table，只有第一次執行的時候會被呼叫
    func createTable(_ tableName :String, columnsInfo :[String]) -> Bool {
        let sql = "create table if not exists \(tableName) "
            + "(\(columnsInfo.joined(separator: ",")))"
        //使用sqlite3_exec()函式來建立資料表
        //第一個參數就是前面建立資料庫連線後的db
        //第二個參數就是 SQL 指令
        if sqlite3_exec(self.db, sql.cString(using: String.Encoding.utf8), nil, nil, nil) == SQLITE_OK{
            print("資料表建立成功")
            return true
        }
        
        return false
    }
    
    // 新增資料
    func insert(_ tableName :String, rowInfo :[String:String]) -> Bool {
        //這邊需要另一個型別為COpaquePointer的變數statement，用來取得操作資料庫後回傳的資訊
        var statement :OpaquePointer? = nil
        let sql = "insert into \(tableName) " + "(\(rowInfo.keys.joined(separator: ","))) " + "values (\(rowInfo.values.joined(separator: ",")))"
        //sqlite3_prepare函數將sql指令轉換成一個準備語句物件(編譯好的SQL語句)，同時返回這個物件的指針，這個接口需要一個資料庫連接指針以及一個要準備的包含SQL語句的文本
        //實際上並不執行（evaluate）這個SQL語句，它僅僅為執行準備這個sql語句
        //第一個參數是前面建立資料庫連線後的db，第二個參數是SQL指令
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組( Byte )，設為-1表示不限制讀取量
        //第四個參數是用來取得操作後返回的資訊
        if sqlite3_prepare_v2(self.db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil) == SQLITE_OK {
            //sqlite3_step()用於執行有前面sqlite3_prepare創建的準備語句
            //SQLITE_DONE，完成 sql 語句已經被成功地執行
            if sqlite3_step(statement) == SQLITE_DONE {
                print("成功新增資料")
                sqlite3_finalize(statement)
                return true
            }
            //銷毀之前調用sqlite3_prepare()創建的預處理語句。每一個預處理語句都必須調用這個接口進行銷毀以避免內存泄漏。
            sqlite3_finalize(statement)
        }
        print("新增失敗")
        return false
    }
    
    // 讀取資料
    //呼叫時機：更新列表、顯示更新頁面資料
    func fetch(_ tableName :String, column:String?, cond: String?, order: String?) -> OpaquePointer? {
        var statement :OpaquePointer? //儲存
        var sql = "select \(column ?? "*") from \(tableName)"
        if let condition = cond {
            sql += " where \(condition)"
        }
        
        if let orderBy = order {
            sql += " \(orderBy)"
        }
        sqlite3_prepare_v2(self.db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil)

        return statement
    }
    
    // 更新資料
    //傳入參數資料表名稱，條件cond，更新的資料
    func update(_ tableName :String, cond :String?, rowInfo :[String:String]) -> Bool {
        var statement :OpaquePointer? = nil //用來儲存操作資料庫後回傳的資訊
        var sql = "update \(tableName) set "
        
        // row info
        var info :[String] = []
        for (k, v) in rowInfo {
            info.append("\(k) = \(v)")
        }
        sql += info.joined(separator: ",") //元素之間插入給定的符號，然後回傳新的字串
        // condition
        if let condition = cond {
            sql += " where \(condition)"
        }
        if sqlite3_prepare_v2(self.db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("我更新成功囉")
                return true
            }
            sqlite3_finalize(statement)
        }
        print("我更新失敗囉")
        return false
       
    }
    
    // 刪除資料
    func delete(_ tableName :String, cond :String?) -> Bool {
        var statement :OpaquePointer? = nil
        var sql = "delete from \(tableName)"
        
        // condition條件，以id作為條件
        if let condition = cond {
            sql += " where \(condition)"
        }
        
        if sqlite3_prepare_v2(self.db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("刪除成功")
                return true
            }
            sqlite3_finalize(statement)
        }
        
        return false
    }
    
    deinit {
        print("I,m done")
    }
    
}
