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
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.pushViewController(viewerController, animated: true)
        self.present(viewerController, animated: true, completion: nil)
        
    }
    
    private func photo(at indexPath: IndexPath) -> Photo {
        let section = self.sections[indexPath.section]
        let photo = section.photos[indexPath.row]

        return photo
    }
}

extension PhotoPickerWithNavigationViewController: ViewerControllerDataSource {
    func numberOfItemsInViewerController(_ viewerController: ViewerController) -> Int {
        return (focusedCollection?.sections?.compactMap({ (arg0) -> Int in
            let (_, assets): (String, [TLPHAsset]) = arg0
            return assets.count
        }).reduce(0, { (num1, num2) -> Int in
            return num1 + num2
        }))!
    }
    
    func viewerController(_ viewerController: ViewerController, viewableAt indexPath: IndexPath) -> Viewable {
        let viewable = self.photo(at: indexPath)
//        if let cell = self.collectionView?.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell, let placeholder = cell.imageView?.image {
//            viewable.placeholder = placeholder
//        }
        if let cell = self.collectionView?.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell, let asset = cell.asset, let img = Photo.thumbnail(for: asset) {
            viewable.placeholder = img
        }
        
        return viewable
    }
}

class Section {
    var photos = [Photo]()
    let groupedDate: String

    init(groupedDate: String) {
        self.groupedDate = groupedDate
    }
}

import Photos
class Photo: Viewable {
    var id: String?
    var type: ViewableType = .image
    
    var assetID: String?
    
    var url: String?
    
    var placeholder: UIImage = UIImage()
    
    init(assetID: String) {
        self.assetID = assetID
    }
    
    func media(_ completion: @escaping (UIImage?, NSError?) -> Void) {
        if let _assetID = self.assetID {
            if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [_assetID], options: nil).firstObject {
                Photo.image(for: asset) { image in
                    completion(image, nil)
                }
            }
        } else {
            completion(self.placeholder, nil)
        }
        
    }
    
    static func constructLocalElements(collection: TLAssetsCollection) -> [Section] {
        var sections = [Section]()
        collection.sections?.forEach({ (title, assets) in
            let section = Section(groupedDate: title)
            assets.forEach { (asset) in
                let photo = Photo(assetID: asset.phAsset?.localIdentifier ?? "")
                switch asset.type {
                    case .photo: photo.type = .image
                    case .video: photo.type = .video
                    case .livePhoto: photo.type = .video
                }
                section.photos.append(photo)
            }
            sections.append(section)
        })
        return sections
    }
    
    static func thumbnail(for asset: PHAsset) -> UIImage? {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        requestOptions.resizeMode = .fast

        var returnedImage: UIImage?
        let scaleFactor = UIScreen.main.scale
        let itemSize = CGSize(width: 150, height: 150)
        let targetSize = CGSize(width: itemSize.width * scaleFactor, height: itemSize.height * scaleFactor)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
            // WARNING: This could fail if your phone doesn't have enough storage. Since the photo is probably
            // stored in iCloud downloading it to your phone will take most of the space left making this feature fail.
            // guard let image = image else { fatalError("Couldn't get photo data for asset \(asset)") }

            returnedImage = image
        }

        return returnedImage
    }

    
    static func image(for asset: PHAsset, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic
        requestOptions.resizeMode = .fast

        let bounds = UIScreen.main.bounds.size
        let targetSize = CGSize(width: bounds.width * 2, height: bounds.height * 2)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { image, _ in
            // WARNING: This could fail if your phone doesn't have enough storage. Since the photo is probably
            // stored in iCloud downloading it to your phone will take most of the space left making this feature fail.
            // guard let image = image else { fatalError("Couldn't get photo data for asset \(asset)") }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
