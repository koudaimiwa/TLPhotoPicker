//
//  CustomCellCollectionViewCell.swift
//  TLPhotoPicker_Example
//
//  Created by 三輪航大 on 2021/05/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import TLPhotoPicker
import AVFoundation
import Photos

class CustomCellCollectionViewCell: TLPhotoCollectionViewCell {

    private let selectedColor = UIColor(red: 79/255, green: 0/255, blue: 247/255, alpha: 1.0)
    
    override var duration: TimeInterval? {
        didSet {
            self.durationLabel?.isHidden = self.duration == nil ? true : false
            guard let duration = self.duration else { return }
            self.durationLabel?.text = timeFormatted(timeInterval: duration)
        }
    }
    
    override var isCameraCell: Bool {
        didSet {
            self.orderLabel?.isHidden = self.isCameraCell
        }
    }
    
    override public var selectedAsset: Bool {
        willSet(newValue) {
            self.orderLabel?.layer.borderColor = newValue ? self.selectedColor.cgColor : UIColor.white.cgColor
            self.orderLabel?.backgroundColor = newValue ? self.selectedColor : UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }
    }
    
    override func update(with phAsset: PHAsset) {
        super.update(with: phAsset)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.durationView?.backgroundColor = UIColor.clear
        self.orderLabel?.layer.backgroundColor = UIColor.clear.cgColor
        self.orderLabel?.clipsToBounds = true
        self.orderLabel?.layer.cornerRadius = 12
        self.orderLabel?.layer.borderWidth = 2.5
        self.orderLabel?.layer.borderColor = UIColor.white.cgColor
        self.orderLabel?.layer.shadowColor = UIColor.black.cgColor
        self.orderLabel?.layer.shadowRadius = 12.0
        self.orderLabel?.layer.shadowOpacity = 0.17
        self.orderLabel?.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.orderLabel?.layer.masksToBounds = true
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.durationView?.backgroundColor = UIColor.clear
    }

}
