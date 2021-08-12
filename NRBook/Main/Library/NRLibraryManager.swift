//
//  LibraryManager.swift
//  NRLibraryManager
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

class NRLibraryManager {

    static var hasCreated = false
    static let kTableName  = "bookshelf_table"
    static let kCoverImage = "coverImage"
    static let kBookName   = "bookName"
    static let kProgress   = "progress"
    static let kBookPath   = "bookPath"
    static let kInsertTime = "insertTime"
    static let kAuthorName = "authorName"
    
    class func creatBookshelfTableIfNeeded() {
        if hasCreated {
            return
        }
        let sql = "CREATE TABLE IF NOT EXISTS \(kTableName)" + "(\(kCoverImage) \(DatabaseType.BLOB.rawValue)," +
                                                         "\(kBookName) \(DatabaseType.TEXT.rawValue)," +
                                                         "\(kAuthorName) \(DatabaseType.TEXT.rawValue)," +
                                                         "\(kProgress) \(DatabaseType.INTEGER.rawValue)," +
                                                         "\(kInsertTime) \(DatabaseType.REAL.rawValue)," +
                                                         "\(kBookPath) \(DatabaseType.TEXT.rawValue))"
        let success = NRDBManager.shared.executeUpdate(sql, values: nil)
        if success {
            hasCreated = true
            DebugLog("Bookshelf table creat succeed")
        } else {
            DebugLog("Bookshelf table creat failed")
        }
    }
    
    class func asyncInsertBook(_ book: NRBookModel) {
        DispatchQueue.global().async {
            self.insertBook(book)
        }
    }
    
    class func insertBook(_ book: NRBookModel) {
        self.creatBookshelfTableIfNeeded()
        let sql = "INSERT INTO \(kTableName)" + "(\(kCoverImage), \(kBookName), \(kAuthorName), \(kInsertTime), \(kProgress), \(kBookPath))" + "VALUES (?,?,?,?,?,?)"
        let imgData = book.coverImage?.jpegData(compressionQuality: 0.8)
        let values: [Any] = [imgData ?? NSNull(), book.bookName, book.authorName ?? NSNull(), book.insertTime, book.progress, book.bookPath]
        let success = NRDBManager.shared.executeUpdate(sql, values: values)
        if !success {
            DebugLog("Insert failed")
        } else {
            DebugLog("Insert succeed")
        }
        NRDBManager.shared.close()
    }
    
    class func deleteBook(_ book: NRBookModel) {
        self.creatBookshelfTableIfNeeded()
        let sql = "DELETE FROM \(kTableName) WHERE \(kBookName) = ? AND \(kBookPath) = ?"
        let success = NRDBManager.shared.executeUpdate(sql, values: [book.bookName, book.bookPath])
        if !success {
            DebugLog("Delete failed")
        } else {
            DebugLog("Delete succeed")
        }
        NRDBManager.shared.close()
    }
    
    class func updateBookPregress(_ progress: Int, bookPath: String) {
        self.creatBookshelfTableIfNeeded()
        let sql = "UPDATE \(kTableName) SET \(kProgress) = ? WHERE \(kBookPath) = ?"
        let success = NRDBManager.shared.executeUpdate(sql, values: [progress, bookPath])
        if !success {
            DebugLog("Update failed")
        } else {
            DebugLog("Update succeed")
        }
        NRDBManager.shared.close()
    }
    
    class func loadBookWithPath(_ path: String, completion: (NRBookModel?, Error?) -> Void) {
        self.creatBookshelfTableIfNeeded()
        let sql = "SELECT * FROM \(kTableName) WHERE \(kBookPath) = ?"
        NRDBManager.shared.executeQuery(sql, values: [path]) {
            guard let resultSet = $0 else { completion(nil, $1); return }
            var bookList = [NRBookModel]()
            while resultSet.next() {
                let book = NRBookModel.init(with: resultSet.string(forColumn: kBookName)!, path: resultSet.string(forColumn: kBookPath)!)
                if let imgData = resultSet.data(forColumn: kCoverImage) {
                    book.coverImage = UIImage.init(data: imgData)
                }
                book.authorName = resultSet.string(forColumn: kAuthorName)
                book.insertTime = Double(resultSet.int(forColumn: kInsertTime))
                book.progress = Int(resultSet.int(forColumn: kProgress))
                bookList.append(book)
            }
            completion(bookList.first, nil)
        }
        NRDBManager.shared.close()
    }
    
    class func loadBookList(completion: ([NRBookModel]?, Error?) -> Void) {
        self.creatBookshelfTableIfNeeded()
        let sql = "SELECT * FROM \(kTableName) ORDER BY \(kInsertTime) DESC"
        NRDBManager.shared.executeQuery(sql, values: nil) {
            guard let resultSet = $0 else { completion(nil, $1); return }
            var bookList = [NRBookModel]()
            while resultSet.next() {
                let book = NRBookModel.init(with: resultSet.string(forColumn: kBookName)!, path: resultSet.string(forColumn: kBookPath)!)
                if let imgData = resultSet.data(forColumn: kCoverImage) {
                    book.coverImage = UIImage.init(data: imgData)
                }
                book.authorName = resultSet.string(forColumn: kAuthorName)
                book.insertTime = Double(resultSet.int(forColumn: kInsertTime))
                book.progress = Int(resultSet.int(forColumn: kProgress))
                bookList.append(book)
            }
            completion(bookList, nil)
        }
        NRDBManager.shared.close()
    }
}
