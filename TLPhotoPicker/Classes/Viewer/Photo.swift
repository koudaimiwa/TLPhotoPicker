//
//  Photo.swift
//  TLPhotoPicker
//
//  Created by 三輪航大 on 2021/05/17.
//

import Foundation
import Photos

public class Section {
    public var photos = [Photo]()
    let groupedDate: String

    init(groupedDate: String) {
        self.groupedDate = groupedDate
    }
}

public class Photo: Viewable {
    var id: String?
    public var type: ViewableType = .image
    
    public var assetID: String?
    
    public var url: String?
    
    public var placeholder: UIImage = UIImage()
    
    init(assetID: String) {
        self.assetID = assetID
    }
    
    public func media(_ completion: @escaping (UIImage?, NSError?) -> Void) {
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
    
    static public func constructLocalElements(collection: TLAssetsCollection) -> [Section] {
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
    
    static public func thumbnail(for asset: PHAsset) -> UIImage? {
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

