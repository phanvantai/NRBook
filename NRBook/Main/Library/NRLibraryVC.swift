//
//  LibraryViewController.swift
//  NRLibraryVC
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

class NRLibraryVC: NRBaseVC {
    
    var libraryCollectionView: UICollectionView!
    var emptyView: EmptyView?
    var bookList = [NRBookModel]()
    
    let sectionEdgeInsetsLR: CGFloat = 30
    let minimumInteritemSpacing: CGFloat = 25
    
    var rowCount: Int = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Library"
        
        setupCollectionView()
        
        addNotifications()
        
        loadLocalBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        libraryCollectionView.frame = view.bounds
        emptyView?.frame = view.bounds
    }
    
    // MARK: - Notifications
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(importEpubBookNotification(_:)), name: Notification.importEpubBookNotification, object: nil)
    }
    
    @objc func importEpubBookNotification(_ notification: Notification) {
        guard let bookPath = notification.object as? String else { return }
        
        let epubParser: FREpubParser = FREpubParser()
        let fullPath = NRBookFileManager.bookUnzipPath + "/" + bookPath
        guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: fullPath, unzipPath: NRBookFileManager.bookUnzipPath) else { return }
        let book = NRBookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: SCREEN_WIDTH * 0.5)
        bookList.insert(book, at: 0)
        libraryCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    func loadLocalBooks() {
        self.updateEmptyViewState(.loading)
        DispatchQueue.global().async {
            var bookList: [NRBookModel]?
            NRLibraryManager.loadBookList { (list, error) in
                if error != nil {
                    DebugLog(error)
                }
                bookList = list
            }
            #if DEBUG
            if bookList?.count == 0 {
                bookList = self.testBooks()
            }
            #endif
            
            DispatchQueue.main.async {
                self.bookList = bookList ?? [NRBookModel]()
                self.libraryCollectionView.reloadData()
                self.updateEmptyViewState(.empty)
            }
        }
    }
    
    func testBooks() -> [NRBookModel] {
        var bookList = [NRBookModel]()
        if let book = testBook(name: "alice") {
            bookList.append(book)
        }
        if let book = testBook(name: "chair") {
            bookList.append(book)
        }
        return bookList
    }
    
    func testBook(name: String) -> NRBookModel? {
        let epubParser: FREpubParser = FREpubParser()
        
        let bundle = Bundle.main
        var bookPath = bundle.path(forResource: name, ofType: "epub")
        if bookPath == nil {
            let budlePath = bundle.path(forResource: "EpubBooks", ofType: "bundle")
            let resourcesBundle = Bundle.init(path: budlePath ?? "")
            bookPath = resourcesBundle?.path(forResource: name, ofType: "epub")
        }
        if let bookPath = bookPath {
            guard let bookMeta: FRBook = try? epubParser.readEpub(epubPath: bookPath, unzipPath: NRBookFileManager.bookUnzipPath) else { return nil}
            let bookPath = name + "." + NRBookFileType.Epub.rawValue
            let book = NRBookModel.model(with: bookMeta, path: bookPath, imageMaxWidth: SCREEN_WIDTH * 0.5)
            NRLibraryManager.asyncInsertBook(book)
            return book
        }
        return nil
    }
}

// MARK: - SetupUI
extension NRLibraryVC {
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing
        
        libraryCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        libraryCollectionView.dataSource = self
        libraryCollectionView.delegate = self
        libraryCollectionView.backgroundColor = UIColor.white
        libraryCollectionView.alwaysBounceVertical = true
        libraryCollectionView.register(NRBookCell.self, forCellWithReuseIdentifier: "NRBookCell")
        self.view.addSubview(libraryCollectionView)
    }
    
    func updateEmptyViewState(_ state: EmptyState) {
        if (bookList.count == 0) {
            if emptyView == nil {
                emptyView = EmptyView.init(frame: self.view.bounds)
                emptyView?.setTitle("Empty", subTitle: "Fill up the bookshelf with good books~")
                self.view.addSubview(emptyView!)
            }
            emptyView?.state = state
            emptyView?.isHidden = false
            self.view.bringSubviewToFront(emptyView!)
        } else {
            emptyView?.isHidden = true
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension NRLibraryVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let bookCell: NRBookCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NRBookCell", for: indexPath) as! NRBookCell
        bookCell.bookModel = bookList[indexPath.item]
        bookCell.delegate = self
        return bookCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let available = collectionView.width - minimumInteritemSpacing * (CGFloat(rowCount) - 1) - sectionEdgeInsetsLR * 2
        let width = floor(available / CGFloat(rowCount))
        return CGSize.init(width: width, height: NRBookCell.cellHeightWithWidth(width))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 15, left: sectionEdgeInsetsLR, bottom: 15, right: sectionEdgeInsetsLR)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        //let book = bookList[indexPath.item]
        //let readerCenter = ReaderCenterViewController.init(withPath: book.fullPath)
        //readerCenter.delegate = self
        //self.navigationController?.pushViewController(readerCenter, animated: true)
    }
}

// MARK: - NRBookCellDelegate
extension NRLibraryVC: NRBookCellDelegate {
    func bookCellDidClickOptionButton(_ cell: NRBookCell) {
        guard let bookModel = cell.bookModel else { return }
        let bookFullPath = bookModel.fullPath
        let bookPathUrl = URL.init(fileURLWithPath: bookFullPath)
        let epubItem = ActivityItemProvider.init(shareUrl: bookPathUrl)
        epubItem.title = bookModel.bookName
        epubItem.icon = bookModel.coverImage
        
        let delete = Activity.init(withTitle: "Delete", type: UIActivity.ActivityType.delete)
        delete.image = UIImage.init(named: "trash")
        
        let activityVC = UIActivityViewController.init(activityItems: [epubItem], applicationActivities: [delete])
        // Try to exclude add tags, but failed. I don't konw why 😭
        //        let tagType = UIActivity.ActivityType.init("com.apple.DocumentManagerUICore.AddTagsActionExtension")
        //        activityVC.excludedActivityTypes = [tagType]
        let cellIndex = libraryCollectionView.indexPath(for: cell)
        activityVC.completionWithItemsHandler = { (type: UIActivity.ActivityType?, finish: Bool, items: [Any]?, error: Error?) in
            if type == UIActivity.ActivityType.delete {
                self.showDeleteAlert(with: bookFullPath, at: cellIndex)
            }
        }
        let popover = activityVC.popoverPresentationController
        if popover != nil {
            popover?.sourceView = cell.optionButton
        }
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func showDeleteAlert(with bookPath: String, at index: IndexPath?) {
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertVC.view.tintColor = .black
        let delete = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            self.deleteBook(at: index, bookPath: bookPath)
        }
        let cancle = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(delete)
        alertVC.addAction(cancle)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func deleteBook(at index: IndexPath?, bookPath: String) {
        guard let index = index else { return }
        let book = bookList[index.item]
        NRLibraryManager.deleteBook(book)
        bookList.remove(at: index.item)
        libraryCollectionView.deleteItems(at: [index])
        self.updateEmptyViewState(.empty)
        do {
            try FileManager.default.removeItem(atPath: bookPath)
        } catch  {
            DebugLog(error)
        }
    }
}
