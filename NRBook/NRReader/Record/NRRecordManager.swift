//
//  NRRecordManager.swift
//  NRRecordManager
//
//  Created by Tai Phan Van on 15/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import Foundation

class NRRecordManager {
    
    static let DIRECTORY_PATH = "/ReadingRecord"
    
    class func readingRecord(with bookName: String) -> NRRecordModel {
        
        if let readingRecord = NSKeyedUnarchiver.unarchiveObject(withFile: self.readingRecordPath(with: bookName)) as? NRRecordModel {
            return readingRecord
        }
        return NRRecordModel(0, 0, NSMakeRange(0, 0))
    }
    
    class func readingRecordPath(with bookName: String) -> String  {
        let dirPath = DOCUMENT_DIRECTORY_PATH + DIRECTORY_PATH
        let isExist = FileManager.default.fileExists(atPath: dirPath)
        if !isExist {
            do {
                try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: dirPath), withIntermediateDirectories: true, attributes: nil)
            } catch  {
                DebugLog("Create Directory faile: \(error)")
                return DOCUMENT_DIRECTORY_PATH + "/" + bookName
            }
        }
        return dirPath + "/" + bookName
    }
    
    class func setReadingRecord(record: NRRecordModel, bookName: String) -> Void {
        DispatchQueue.global().async {
            NSKeyedArchiver.archiveRootObject(record, toFile: self.readingRecordPath(with: bookName))
        }
    }
}
