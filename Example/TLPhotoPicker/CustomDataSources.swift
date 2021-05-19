//
//  CustomDataSources.swift
//  TLPhotoPicker_Example
//
//  Created by wade.hawk on 21/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Photos
import TLPhotoPicker

struct CustomDataSources: TLPhotopickerDataSourcesProtocol {
    
    func headerReferenceSize() -> CGSize {
        return CGSize(width: 320, height: 50)
    }
    
    func footerReferenceSize() -> CGSize {
        return CGSize.zero
    }
    
    func supplementIdentifier(kind: String) -> String {
        if kind == UICollectionView.elementKindSectionHeader {
            return "CustomHeaderView"
        }else {
            return "CustomFooterView"
        }
    }
    
    func registerSupplementView(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: "CustomHeaderView", bundle: Bundle.main)
        collectionView.register(headerNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "CustomHeaderView")
        let footerNib = UINib(nibName: "CustomFooterView", bundle: Bundle.main)
        collectionView.register(footerNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "CustomFooterView")
    }
    
    func configure(supplement view: UICollectionReusableView, section: (title: String, assets: [TLPHAsset]), isAllSelected: Bool, toggleSelection: ((_ selected: Bool) -> Void)?) {
        if let reuseView = view as? CustomHeaderView {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy年 M月dd日"
            dateFormat.locale = Locale.current
            
            if let date = section.assets.first?.phAsset?.creationDate {
                reuseView.titleLabel.text = dateFormat.string(from: date)
            }
            reuseView.toggleCheckBtn(isAllSelected: isAllSelected)
            reuseView.toggleAllBtn = toggleSelection
        } else if let reuseView = view as? CustomFooterView {
            reuseView.titleLabel.text = "Footer"
        }
    }
    
    func toggleSelection(supplement view: UICollectionReusableView?, isAllSelected: Bool) {
        guard let _view = view, let reuseView = _view as? CustomHeaderView else {
            return
        }
        reuseView.toggleCheckBtn(isAllSelected: isAllSelected)
    }
}
