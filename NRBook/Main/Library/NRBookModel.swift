//
//  NRBookModel.swift
//  NRBookModel
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

/**
 Define a book in library
 */
class NRBookModel {
    
    /// Cover image book
    var coverImage: UIImage?
    /// Name of book
    var bookName: String
    /// Author Name
    var authorName: String?
    /// Progress of reading
    var progress: Int = 0
    /// Path of book (in document directory)
    var bookPath: String
    
    /// time book be added to library
    lazy var insertTime: TimeInterval = NSDate().timeIntervalSince1970
    
    var fullPath: String {
        get {
            return NRBookFileManager.bookUnzipPath + "/" + bookPath
        }
    }
    
    init(with bookName: String, path: String) {
        self.bookName = bookName
        self.bookPath = path
    }
    
    class func model(with bookMeta: FRBook, path: String, imageMaxWidth: CGFloat?) -> NRBookModel {
        let book = NRBookModel.init(with: bookMeta.title ?? "No title", path: path)
        if let coverUrl = bookMeta.coverImage?.fullHref {
            if let imageMaxWidth = imageMaxWidth {
                book.coverImage = UIImage.init(contentsOfFile: coverUrl)?.scaled(toWidth:imageMaxWidth, scale: 2)
            } else {
                book.coverImage = UIImage.init(contentsOfFile: coverUrl)
            }
        }
        book.authorName = bookMeta.authorName
        return book
    }
}

