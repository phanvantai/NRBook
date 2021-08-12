//
//  NRUtilities.swift
//  NRUtilities
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

public func DebugLog<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
    print("[Debug] \((file as NSString).lastPathComponent) \(function) \(line): \(message)")
#endif
}

public let APP_THEME_COLOR = UIColor.init(red: 1, green: 156/255.0, blue: 0, alpha: 1)


public let SEPARATOR_COLOR = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.05)

public let SCREEN_WIDTH = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

/// Documents
public let DOCUMENT_DIRECTORY_PATH: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
/// Library
public let LIBRARY_DIRECTORY_PATH: String = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
/// Library/Caches
public let CACHES_DIRECTORY_PATH: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
