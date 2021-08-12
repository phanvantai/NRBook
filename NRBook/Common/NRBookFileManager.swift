//
//  NRBookFileManager.swift
//  NRBookFileManager
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit
import SSZipArchive

// Import Epub
extension Notification {
    static let importEpubBookNotification = Notification.Name("NRImportEpubBook")
}

enum NRBookFileType: String {
    case Epub = "epub"
}

enum DirectoryType: String {
    case Books = "books"
    /// AirDrop
    case Inbox = "Inbox"
    case Share = "Share"
}

class NRBookFileManager: NSObject {
    static let shared: NRBookFileManager = NRBookFileManager()
    
    /// epub books path
    static let bookUnzipPath: String = {
        let path = DOCUMENT_DIRECTORY_PATH + "/" + DirectoryType.Books.rawValue
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: URL.init(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()
    
    static let bookSharePath: String = {
        let path = DOCUMENT_DIRECTORY_PATH + "/" + DirectoryType.Share.rawValue
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: URL.init(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()
    
    var fileQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "reader_file_queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        return queue
    }()
    
    var bookPathList: [String] {
        get {
            // Note: subpathsOfDirectory will return all subpaths (recursively)
            guard let pathList = try? FileManager.default.contentsOfDirectory(atPath: NRBookFileManager.bookUnzipPath) else { return [String]() }
            var bookPaths = [String]()
            for path in pathList {
                if !path.hasSuffix(NRBookFileType.Epub.rawValue) {
                    continue
                }
                bookPaths.append(NRBookFileManager.bookUnzipPath + "/" + path)
            }
            return bookPaths
        }
    }
    
    func deleteAirDropFileContents() {
        let path = DOCUMENT_DIRECTORY_PATH + "/" + DirectoryType.Inbox.rawValue
        try? FileManager.default.removeItem(atPath: path)
        DebugLog("")
    }
    
    func addEpubBookByShareUrl(_ url: URL, completion: @escaping (_ bookPath: String?, _ success: Bool) -> Void) {
        // System-Declared Uniform Type Identifiers: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
        let isEpub = url.isFileURL && url.pathExtension == NRBookFileType.Epub.rawValue
        if !isEpub { return }
        
        fileQueue.addOperation {
            defer {
                self.deleteAirDropFileContents()
            }
            
            let bookPath = url.lastPathComponent
            let fullPath = NRBookFileManager.bookUnzipPath + "/" + bookPath
            // filter duplicate file which shared by Airdrop if needed
            if let airdropFlagIdx = bookPath.lastIndex(of: "-") {
                let bookName = String(bookPath[..<airdropFlagIdx]) + "." + NRBookFileType.Epub.rawValue
                if FileManager.default.fileExists(atPath: NRBookFileManager.bookUnzipPath + "/" + bookName) {
                    DebugLog("Duplicate file \(bookName)")
                    DispatchQueue.main.async {
                        completion(fullPath, true)
                    }
                    return
                }
            }
            
            if FileManager.default.fileExists(atPath: fullPath) {
                DebugLog("Exist file \(bookPath)")
                DispatchQueue.main.async {
                    completion(fullPath, true)
                }
                return
            }
            
            // Note: Do not use url.absoluteString, otherwise the following error will be reported： couldn’t be moved to “tmp” because either the former doesn't exist, or the folder containing the latter doesn't exist
            let epubParser: FREpubParser = FREpubParser()
            guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: url.path, unzipPath: NRBookFileManager.bookUnzipPath) else {
                DebugLog("Import failed")
                DispatchQueue.main.async {
                    completion(nil, false)
                }
                return
            }
            let book = NRBookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: SCREEN_WIDTH * 0.5)
            NRLibraryManager.insertBook(book)
            DispatchQueue.main.async {
                completion(fullPath, true)
                NotificationCenter.default.post(name: Notification.importEpubBookNotification, object: bookPath)
            }
        }
    }
    
    func addEpubBookByWifiUploadBookPath(_ path: String) {
        let bookUrl = URL.init(fileURLWithPath: path)
        let isEpub = bookUrl.pathExtension == NRBookFileType.Epub.rawValue
        if !isEpub { return }
        
        fileQueue.addOperation {
            
            let bookPath = bookUrl.lastPathComponent
            let fullPath = NRBookFileManager.bookUnzipPath + "/" + bookPath
            
            if FileManager.default.fileExists(atPath: fullPath) {
                DebugLog("Exist file \(bookPath)")
                return
            }
            let epubParser: FREpubParser = FREpubParser()
            guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: bookUrl.path, unzipPath: NRBookFileManager.bookUnzipPath) else {
                DebugLog("Import failed")
                return
            }
            let book = NRBookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: SCREEN_WIDTH * 0.5)
            NRLibraryManager.insertBook(book)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.importEpubBookNotification, object: bookPath)
            }
        }
    }
}
