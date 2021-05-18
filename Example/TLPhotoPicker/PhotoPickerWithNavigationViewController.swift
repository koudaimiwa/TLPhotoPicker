//
//  PhotoPickerWithNavigationViewController.swift
//  TLPhotoPicker
//
//  Created by wade.hawk on 2017. 7. 24..
//  Copyright © 2017년 CocoaPods. All rights reserved.
//

import Foundation
import TLPhotoPicker

class PhotoPickerWithNavigationViewController: TLPhotosPickerViewController {
    
    private var sections = [Section]()
    
    override func makeUI() {
        super.makeUI()
        self.customNavItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: nil, action: #selector(customAction))
    }
    @objc func customAction() {
        self.delegate?.photoPickerDidCancel()
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.dismissComplete()
            self?.dismissCompletion?()
        }
    }
    
    override func doneButtonTap() {
//        let imagePreviewVC = ImagePreviewViewController()
//        imagePreviewVC.assets = self.selectedAssets.first
        let viewerController = ViewerController(initialIndexPath: IndexPath(row: 0, section: 0), collectionView: collectionView)
            viewerController.dataSource = self
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(viewerController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController?.topViewController is ViewerController {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        sections = Photo.constructLocalElements(collection: focusedCollection!)
        
        let viewerController = ViewerController(initialIndexPath: indexPath, collectionView: collectionView)
        viewerController.dataSource = self
        self.present(viewerController, animated: true, completion: nil)
        
    }
    
    private func photo(at indexPath: IndexPath) -> Photo {
        let section = self.sections[indexPath.section]
        let photo = section.photos[indexPath.row]

        return photo
    }
}
