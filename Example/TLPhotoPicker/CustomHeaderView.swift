//
//  CustomHeaderView.swift
//  TLPhotoPicker_Example
//
//  Created by wade.hawk on 21/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import TLPhotoPicker

class CustomHeaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    
    private let selectedColor = UIColor(red: 79/255, green: 0/255, blue: 247/255, alpha: 1.0).cgColor
    private let borderColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1).cgColor
    
    public var toggleAllBtn: ((_ selected: Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBtn.tag = 0
        self.checkBtn.layer.backgroundColor = UIColor.clear.cgColor
        self.checkBtn.clipsToBounds = true
        self.checkBtn.layer.cornerRadius = 12
        self.checkBtn.layer.borderWidth = 2.5
        self.checkBtn.layer.borderColor = borderColor
        self.checkBtn.layer.shadowColor = UIColor.black.cgColor
        self.checkBtn.layer.shadowRadius = 12.0
        self.checkBtn.layer.shadowOpacity = 0.17
        self.checkBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.checkBtn.layer.masksToBounds = true
        self.checkBtn.addTarget(self, action: #selector(selectAllAssets), for: .touchUpInside)
    }
    
    @objc private func selectAllAssets() {
        toggleAllBtn?(checkBtn.image(for: .normal) == nil)
        toggleCheckBtn(isAllSelected: checkBtn.image(for: .normal) == nil)
    }
    
    open func toggleCheckBtn(isAllSelected: Bool) {
        if !isAllSelected {
            checkBtn.setImage(nil, for: .normal)
            checkBtn.layer.borderColor = borderColor
            checkBtn.layer.backgroundColor = UIColor.clear.cgColor
        } else {
            checkBtn.setImage(TLBundle.podBundleImage(named: "check")!, for: .normal)
            checkBtn.imageView?.contentMode = .scaleAspectFit
            checkBtn.contentHorizontalAlignment = .fill
            checkBtn.contentVerticalAlignment = .fill
            checkBtn.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            checkBtn.tintColor = .white
            checkBtn.layer.borderColor = self.selectedColor
            checkBtn.layer.backgroundColor = self.selectedColor
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkBtn.setImage(nil, for: .normal)
        checkBtn.layer.borderColor = borderColor
        checkBtn.layer.backgroundColor = UIColor.clear.cgColor
    }
}
