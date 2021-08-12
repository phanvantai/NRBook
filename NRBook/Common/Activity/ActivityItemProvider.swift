//
//  ActivityItemProvider.swift
//  ActivityItemProvider
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit
import SSZipArchive
import LinkPresentation

class ActivityItemProvider: UIActivityItemProvider {

    var title: String?
    var icon: UIImage?
    var shareUrl: URL
    var originalshareUrl: URL!
    var type: UIActivity.ActivityType?
    
    init(shareUrl: URL) {
        originalshareUrl = shareUrl
        // There is a problem with Library/Caches as the compressed output path under iPhone, and the simulator is OK. No reason yet 😅
        self.shareUrl = URL.init(fileURLWithPath: NRBookFileManager.bookSharePath + shareUrl.lastPathComponent)
        super.init(placeholderItem: self.shareUrl)
    }
    
    override var item: Any {
        if !FileManager.default.fileExists(atPath: shareUrl.path) {
            SSZipArchive.createZipFile(atPath: shareUrl.path, withContentsOfDirectory: originalshareUrl.path)
        }
        return shareUrl
    }
    
    override var activityType: UIActivity.ActivityType? {
        return type
    }
    
    @available(iOS 13.0, *)
    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.url = shareUrl
        metadata.title = title
        if let icon = icon {
            metadata.iconProvider = NSItemProvider(object: icon)
        }
        return metadata
    }
}
