//
//  NRBookPage.swift
//  NRBookPage
//
//  Created by Tai Phan Van on 15/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

/**
 Define a page of reader
 */
class NRBookPage {
    
    /// Color of text
    var textColorHex: String!
    
    /// Range of content
    lazy var range = NSMakeRange(0, 0)
    
    /// Content of page
    lazy var content: NSAttributedString = NSAttributedString.init(string: "")
    
    var pageIndex: Int = 0
    var chapterIndex: Int = 0
    
    /// Chapter name of page
    var chapterName: String?
    
    /// Number of page display on reader screen
    var displayPageIndex: Int?
    
    /// Page is a bookmark or not
    var isBookmark = false
    
    /// Init a page with pageIndex & chapterIndex
    class func bookPage(withPageIndex pageIndex: Int, chapterIndex: Int) -> NRBookPage {
        let page = NRBookPage()
        page.pageIndex = pageIndex
        page.chapterIndex = chapterIndex
        return page
    }
    
    /// Update color for text content
    func updateTextColor(_ textColor: UIColor) {
        guard let mutableContent = content.mutableCopy() as? NSMutableAttributedString else { return }
        guard let tempContent = mutableContent.mutableCopy() as? NSMutableAttributedString else { return }
        tempContent.enumerateAttributes(in: NSMakeRange(0, tempContent.length), options: [.longestEffectiveRangeNotRequired]) { (value: [NSAttributedString.Key : Any], range, stop) in
            if !value.keys.contains(.link) {
                mutableContent.addAttribute(.foregroundColor, value: textColor, range: range)
            }
        }
        self.content = mutableContent
    }
}
