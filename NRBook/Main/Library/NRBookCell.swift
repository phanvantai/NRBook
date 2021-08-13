//
//  NRBookCell.swift
//  NRBookCell
//
//  Created by Tai Phan Van on 14/08/2021.
//  Copyright © 2021 november-rain. All rights reserved.
//

import UIKit

/// Book cover ratio (width/height)
public let bookCoverScale: CGFloat = 0.72
/// Height of bottom container
private let bookCellBottomHeight: CGFloat = 40

protocol NRBookCellDelegate: AnyObject {
    func bookCellDidClickOptionButton(_ cell: NRBookCell)
}

class NRBookCell: UICollectionViewCell {
    
    let pogressH: CGFloat = 20
    var bookCoverView = UIImageView()
    var bookCoverShadow = UIView()
    var progressLabel = UILabel()
    var optionButton = UIButton.init(type: .custom)
    
    weak var delegate: NRBookCellDelegate?
    
    // MARK: - Override
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookCoverView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var coverH: CGFloat = 0
        var coverW: CGFloat = 0
        if let coverImg = bookCoverView.image {
            let imageScale = coverImg.size.width / coverImg.size.height
            if imageScale <= bookCoverScale {
                coverH = self.width / bookCoverScale
                coverW = coverH * imageScale
            } else {
                coverW = self.width
                coverH = coverW / imageScale
            }
        } else {
            coverH = self.width / bookCoverScale
            coverW = self.width
        }
        let coverX: CGFloat = (self.width - coverW) * 0.5
        let coverY: CGFloat = self.height - coverH - bookCellBottomHeight
        bookCoverView.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        bookCoverShadow.frame = bookCoverView.frame
        
        let progressY = bookCoverView.frame.maxY + (bookCellBottomHeight - pogressH) * 0.5
        let progressW = ((progressLabel.text ?? "") as NSString).size(withAttributes: [.font: progressLabel.font!]).width + 12
        progressLabel.frame = CGRect(x: 0, y: progressY, width: progressW, height: pogressH)
        let optionBtnW: CGFloat = 30
        optionButton.frame = CGRect(x: self.width - optionBtnW, y: progressY, width: optionBtnW, height: bookCellBottomHeight)
    }
    
    // MARK: - Private
    private func setupSubviews() {
        
        contentView.backgroundColor = .white
        
        // https://stackoverflow.com/questions/3690972/why-maskstobounds-yes-prevents-calayer-shadow
        let cornerRadius: CGFloat = 3
        bookCoverShadow.backgroundColor = .white
        bookCoverShadow.layer.cornerRadius = cornerRadius
        bookCoverShadow.layer.shadowOpacity = 0.25
        bookCoverShadow.layer.shadowOffset = CGSize.init(width: 0, height: 10)
        contentView.addSubview(bookCoverShadow)
        
        bookCoverView.layer.masksToBounds = true
        bookCoverView.layer.cornerRadius = cornerRadius
        contentView.addSubview(bookCoverView)

        progressLabel.layer.cornerRadius = pogressH * 0.5
        progressLabel.layer.masksToBounds = true
        progressLabel.font = UIFont.systemFont(ofSize: 13)
        progressLabel.textAlignment = .left
        contentView.addSubview(progressLabel)
        
        optionButton.setImage(UIImage.init(named: "more_icon"), for: .normal)
        optionButton.contentHorizontalAlignment = .right
        optionButton.addTarget(self, action: #selector(didClickOptionButton(_:)), for: .touchUpInside)
        contentView.addSubview(optionButton)
    }
    
    @objc func didClickOptionButton(_ button: UIButton) {
        self.delegate?.bookCellDidClickOptionButton(self)
    }
    
    func updateProgressLabelText() {
        var textColor: UIColor?
        var bgColor: UIColor?
        var textAlignment: NSTextAlignment?
        if let progress = bookModel?.progress {
            if progress <= 0 {
                progressLabel.text = "Added"
                bgColor = UIColor.rgba(255, 156, 0, 1)
                textAlignment = .center
                textColor = .white
            } else if progress >= 100 {
                progressLabel.text = "Finished"
            } else {
                progressLabel.text = "\(progress)%"
            }
        } else {
            progressLabel.text = ""
        }
        progressLabel.textColor = textColor ?? UIColor.hexColor("666666")
        progressLabel.textAlignment = textAlignment ?? .left
        progressLabel.backgroundColor = bgColor ?? UIColor.clear
    }
    
    // MARK: - Public
    public class func cellHeightWithWidth(_ width: CGFloat) -> CGFloat {
        return width / bookCoverScale + bookCellBottomHeight
    }
    
    public var bookModel: NRBookModel? {
        didSet {
            bookCoverView.image = bookModel?.coverImage
            self.updateProgressLabelText()
        }
    }
}
