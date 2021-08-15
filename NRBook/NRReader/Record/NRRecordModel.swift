//
//  NRRecordModel.swift
//  NRRecordModel
//
//  Created by Tai Phan Van on 15/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import Foundation

class NRRecordModel: NSObject, NSCoding {
    var chapterIndex: Int = 0
    var pageIndex: Int = 0
    var textRange = NSMakeRange(0, 0)
    
    init(_ chapterIdx: Int, _ pageIdx: Int, _ range: NSRange) {
        self.chapterIndex = chapterIdx
        self.pageIndex = pageIdx
        self.textRange = range
    }
    
    required init?(coder: NSCoder) {
        chapterIndex = coder.decodeInteger(forKey: "chapterIndex")
        pageIndex =  coder.decodeInteger(forKey: "pageIndex")
        if let range = coder.decodeObject(forKey: "textRange") as? NSRange {
            textRange = range
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(chapterIndex, forKey: "chapterIndex")
        coder.encode(pageIndex, forKey: "pageIndex")
        coder.encode(textRange, forKey: "textRange")
    }
}
