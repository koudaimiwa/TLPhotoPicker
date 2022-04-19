import UIKit
import Photos

public enum ViewableType: String {
    case image
    case video
    case livePhoto
}

public protocol Viewable {
    var type: ViewableType { get }
    var assetID: String? { get }
    var placeholder: UIImage { get }
    var avplayer: AVPlayer? { get }
    var livePhoto: PHLivePhoto? { get }
    var isMuted: Bool? { get }
    
    func media(_ completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void)
    func livePhotoMedia(_ completion: @escaping (_ image: PHLivePhoto?, _ error: NSError?) -> Void)
}
