//
//  DatabaseManager.swift
//  DatabaseManager
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

/**
 ORM: Object Relational Mapping
 FMDB: https://github.com/ccgus/fmdb
 SQLite visualization tool: https://github.com/sqlitebrowser/sqlitebrowser
 Frequently Asked Questions: https://www.sqlite.org/faq.html
 
 The SQLite command
    CREATE | creates a new table, a view of a table, or other objects in the database.
    ALTER | Modify an existing database object in the database, such as a table.
    DROP | Delete the entire table, or view of the table, or other objects in the database.
    INSERT | Create a record.
    UPDATE | Modify the record.
    DELETE | Delete records.
    SELECT | Retrieve certain records from one or more tables.
 */

import FMDB

/**
 SQLite Storage type
 */
enum DatabaseType: String {
    /// Value is a NULL value
    case NULL    = "NULL"
    
    /// The value is a signed integer, stored in 1, 2, 3, 4, 6, or 8 bytes depending on the size of the value
    case INTEGER = "INTEGER"
    
    /// The value is a floating point value, stored as an 8-byte IEEE floating point number.
    case REAL    = "REAL"
    
    /// The value is a text string, stored using the database encoding (UTF-8, UTF-16BE, or UTF-16LE).
    case TEXT    = "TEXT"
    
    /// The value is a blob data, completely stored according to its input.
    case BLOB    = "BLOB"
}

class DatabaseManager: NSObject {
    static let shared: DatabaseManager = DatabaseManager()
    
    lazy var fmdbQueue: FMDatabaseQueue? = {
        var dbPath = DOCUMENT_DIRECTORY_PATH
        dbPath = dbPath.appendingPathComponent("NRBook.sqlite")
        DebugLog(dbPath);
        let queue = FMDatabaseQueue.init(path: dbPath)
        return queue
    }()
    
    func close() {
        fmdbQueue?.close()
    }
    
    /**
     Applies to SELECT statement
     1. executeQuery("SELECT x, y, z FROM test", values: nil)
     2. Get all available fields: SELECT * FROM table_name
     */
    func executeQuery(_ sql: String, values: [Any]?, completion: (FMResultSet?, Error?) -> Void) {
        fmdbQueue?.inDatabase({ (db) in
            do {
                let resultSet = try db.executeQuery(sql, values: values)
                completion(resultSet, nil)
            } catch {
                completion(nil, error)
                DebugLog("failed: \(error.localizedDescription)")
            }
        })
    }
    /**
     Applicable to statements other than SELECT
     1. executeUpdate("create table test(x text, y text, z text)", values: nil)
     2. executeUpdate("insert into test (x, y, z) values (?, ?, ?)", values: ["a", "b", "c"]
     */
    func executeUpdate(_ sql: String, values: [Any]?) -> Bool {
        
        var success = false
        fmdbQueue?.inDatabase({ (db) in
            do {
                try db.executeUpdate(sql, values: values)
                success = true
            } catch {
                DebugLog("failed: \(error.localizedDescription)")
            }
        })
        return success
    }
}
