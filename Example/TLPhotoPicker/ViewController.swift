//
//  ViewController.swift
//  TLPhotoPicker
//
//  Created by wade.hawk on 05/09/2017.
//  Copyright (c) 2017 wade.hawk. All rights reserved.
//

import UIKit
import TLPhotoPicker
import PhotosUI

class ViewController: UIViewController,TLPhotosPickerViewControllerDelegate {
    
    var selectedAssets = [TLPHAsset]()
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
        
    private func testLivePhotoView() {
        let liveView = PHLivePhotoView(frame: view.frame)
        liveView.contentMode = .scaleAspectFit
        let videoUrl = URL(string: "https://firebasestorage.googleapis.com/v0/b/trip-7a2be.appspot.com/o/article_images%2F300DA4A0-5A51-40D7-94B4-AD85784E64B2.mp4?alt=media&token=93d3e3c0-1fbc-4f5d-8a7c-5fb303d66ed9")!
        var savedVideoUrl: URL!
        do {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            if videoUrl.pathExtension != ".mov" || videoUrl.pathExtension != ".MOV" {
                let asset = AVAsset(url: videoUrl)
                let _ = (asset as! AVURLAsset).convertMp4ToMov(completion: { [weak self] (outputURL) in
                    defer {
                        dispatchGroup.leave()
                    }
                    savedVideoUrl = outputURL
                })
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                LivePhoto.generate(from: nil, videoURL: savedVideoUrl) { (progress) in
                } completion: { [weak self] (livePhoto, resources) in
                    guard let _self = self else { return }
                    liveView.livePhoto = livePhoto
                    _self.view.addSubview(liveView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        LivePhoto.deleteTempFolderItems()
                    }
                }
            }
        } catch let error {
            print(error)
        }
    }
        
    @IBAction func iosPickerButtonTap(_ sender: Any) {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 0
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
        
    @IBAction func pickerButtonTap() {
        let viewController = CustomPhotoPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
//        configure.usedPrefetch = true
        configure.numberOfColumn = 3
        configure.groupByFetch = .day
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        viewController.logDelegate = self

        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func onlyVideoRecording(_ sender: Any) {
        let viewController = CustomPhotoPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.allowedPhotograph = false
        configure.allowedVideoRecording = true
        configure.mediaType = .video
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        viewController.logDelegate = self

        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func pickerWithCustomCameraCell() {
        let viewController = CustomPhotoPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        if #available(iOS 10.2, *) {
            configure.cameraCellNibSet = (nibName: "CustomCameraCell", bundle: Bundle.main)
        }
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        self.present(viewController.wrapNavigationControllerWithoutBar(), animated: true, completion: nil)
    }
    
    @IBAction func pickerWithCustomBlackStyle() {
        let viewController = CustomBlackStylePickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        self.present(viewController, animated: true, completion: nil)
    }

    @IBAction func pickerWithNavigation() {
        let viewController = PhotoPickerWithNavigationViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.groupByFetch = .day
        configure.usedCameraButton = false
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        self.present(viewController.wrapNavigationControllerWithoutBar(), animated: true, completion: nil)
    }
    
    @IBAction func pickerWithCustomRules() {
        let viewController = PhotoPickerWithNavigationViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        viewController.canSelectAsset = { [weak self] asset -> Bool in
            if asset.pixelHeight != 300 && asset.pixelWidth != 300 {
                self?.showUnsatisifiedSizeAlert(vc: viewController)
                return false
            }
            return true
        }
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.nibSet = (nibName: "CustomCell_Instagram", bundle: Bundle.main)
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        
        self.present(viewController.wrapNavigationControllerWithoutBar(), animated: true, completion: nil)
    }
    
    @IBAction func pickerWithCustomLayout() {
                
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        viewController.customDataSouces = CustomDataSources()
        var configure = TLPhotosPickerConfigure()
        configure.customLocalizedTitle = ["Recents":"すべて","Panoramas":"パノラマ", "Time-lapse":"タイムラプス" ,"Bursts":"バースト","Slo-mo":"スローモーション","Screenshots":"スクリーンショット","Selfies":"セルフィー","Favorites":"お気に入り","Videos":"ビデオ", "Live Photos": "Live Photos"]
        configure.tapHereToChange = "タップして変更"
        configure.nibSet = (nibName: "CustomCellCollectionViewCell", bundle: Bundle.main)
        configure.numberOfColumn = 3
        configure.doneTitle = "追加"
        configure.groupByFetch = .day
        configure.previewAtForceTouch = true
        configure.autoPlay = true
        configure.usedCameraButton = false
        configure.allowedLivePhotos = true
        viewController.configure = configure
        viewController.selectedAssets = self.selectedAssets
        viewController.logDelegate = self
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        getFirstSelectedImage()
        //iCloud or video
//        getAsyncCopyTemporaryFile()
    }
    
    func exportVideo() {
        if let asset = self.selectedAssets.first, asset.type == .video {
            asset.exportVideoFile(progressBlock: { (progress) in
                print(progress)
            }) { (url, mimeType) in
                print("completion\(url)")
                print(mimeType)
            }
        }
    }
    
    func getAsyncCopyTemporaryFile() {
        if let asset = self.selectedAssets.first {
            asset.tempCopyMediaFile(convertLivePhotosToJPG: false, progressBlock: { (progress) in
                print(progress)
            }, completionBlock: { (url, mimeType) in
                print("completion\(url)")
                print(mimeType)
            })
        }
    }
        
    func getFirstSelectedImage() {
        if let asset = self.selectedAssets.first {
            if asset.type == .video {
                asset.videoSize(completion: { [weak self] (size) in
                    self?.label.text = "video file size\(size)"
                })
                return
            }
            if let image = asset.fullResolutionImage {
                print(image)
                self.label.text = "local storage image"
                self.imageView.image = image
            }else {
                print("Can't get image at local storage, try download image")
                asset.cloudImageDownload(progressBlock: { [weak self] (progress) in
                    DispatchQueue.main.async {
                        self?.label.text = "download \(100*progress)%"
                        print(progress)
                    }
                }, completionBlock: { [weak self] (image) in
                    if let image = image {
                        //use image
                        DispatchQueue.main.async {
                            self?.label.text = "complete download"
                            self?.imageView.image = image
                        }
                    }
                })
            }
        }
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
    }

    func photoPickerDidCancel() {
        // cancel
    }

    func dismissComplete() {
        // picker dismiss completion
    }

    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        picker.dismiss(animated: true) {
            let alert = UIAlertController(title: "", message: "Denied albums permissions granted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let alert = UIAlertController(title: "", message: "Denied camera permissions granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }

    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showUnsatisifiedSizeAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Oups!", message: "The required size is: 300 x 300", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: TLPhotosPickerLogDelegate {
    //For Log User Interaction
    func selectedCameraCell(picker: TLPhotosPickerViewController) {
        print("selectedCameraCell")
    }
    
    func selectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("selectedPhoto")
    }
    
    func deselectedPhoto(picker: TLPhotosPickerViewController, at: Int) {
        print("deselectedPhoto")
    }
    
    func selectedAlbum(picker: TLPhotosPickerViewController, title: String, at: Int) {
        print("selectedAlbum")
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
    }
}
