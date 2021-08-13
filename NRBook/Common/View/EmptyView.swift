//
//  EmptyView.swift
//  EmptyView
//
//  Created by Tai Phan Van on 14/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import SnapKit

enum EmptyState: Int {
    case empty
    case loading
}

class EmptyView: UIView {
    var emptyContentView: UIView?
    var loadingContentView: UIView?
    var loadingView: UIActivityIndicatorView?
    lazy var emptyIcon = UIImageView()
    lazy var titleLabel = UILabel()
    var subLabel: UILabel?
    var text: String?
    var subText: String?
    
    var state: EmptyState = .empty {
        willSet {
            if newValue == .empty {
                self.addEmptySubviewsIfNeeded()
                self.loadingView?.stopAnimating()
            } else {
                self.addLoadingViewIfNeeded()
                self.loadingView?.startAnimating()
            }
            self.emptyContentView?.isHidden = newValue != .empty
            self.loadingContentView?.isHidden = newValue == .empty
        }
    }
    
    private func addEmptySubviewsIfNeeded() {
        if emptyContentView != nil {
            return
        }
        emptyContentView = UIView()
        self.addSubview(emptyContentView!)
        emptyContentView!.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        emptyIcon.image = UIImage.init(named: "empty_icon")
        emptyContentView!.addSubview(emptyIcon)
        emptyIcon.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 59, height: 49))
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-20)
        }
        
        titleLabel.textAlignment = .center
        titleLabel.text = text
        titleLabel.textColor = NRReaderConfig.textColor
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        emptyContentView!.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.left.equalTo(self).offset(10)
            make.top.equalTo(emptyIcon.snp.bottom).offset(11)
            make.centerX.equalTo(self)
        }
        self.addSubLabelIfNeeded()
    }
    
    private func addSubLabelIfNeeded() {
        if subText == nil || subLabel != nil {
            return
        }
        subLabel = UILabel()
        subLabel?.text = subText
        subLabel!.numberOfLines = 2
        subLabel!.textColor = NRReaderConfig.textColor.withAlphaComponent(0.5)
        subLabel!.textAlignment = .center
        subLabel!.font = UIFont.systemFont(ofSize: 13)
        emptyContentView!.addSubview(subLabel!)
        subLabel!.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.left.equalTo(self).offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
            make.centerX.equalTo(self)
        }
    }
    
    func addLoadingViewIfNeeded() {
        if loadingContentView != nil {
            return
        }
        loadingContentView = UIView()
        self.addSubview(loadingContentView!)
        loadingContentView!.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        let loadingView = UIActivityIndicatorView.init(style: .gray)
        loadingView.color = .lightGray
        loadingView.hidesWhenStopped = true
        loadingContentView!.addSubview(loadingView)
        self.loadingView = loadingView
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(loadingContentView!)
        }
    }
    
    //MARK: - Public
    func setTitle(_ title: String?, subTitle: String?) {
        text = title
        subText = subTitle
    }
}
