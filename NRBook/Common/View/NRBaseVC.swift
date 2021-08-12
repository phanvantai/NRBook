//
//  NRBaseVC.swift
//  NRBaseVC
//
//  Created by Tai Phan Van on 13/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

open class NRBaseVC: UIViewController {
    
    open var backButtonItem: UIBarButtonItem?
    
    #if DEBUG
    deinit {
        DebugLog(self)
    }
    #endif
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        DebugLog(self)
    }

    open override func viewWillAppear(_ animated: Bool) {
        DebugLog(self)
        return super.viewWillAppear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        DebugLog(self)
        return super.viewDidDisappear(animated)
    }
    
    open func disableLargeTitles() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    open func enableLargeTitles() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
    
    open func setupLeftBackBarButton() {
        let backImg = UIImage.init(named: "arrow_back")?.template
        backButtonItem = UIBarButtonItem.init(image: backImg, style: .plain, target: self, action: #selector(didClickedLeftBackItem(item:)))
        backButtonItem?.tintColor = UIColor.rgba(80, 80, 80, 1)
        self.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    @objc private func didClickedLeftBackItem(item: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
