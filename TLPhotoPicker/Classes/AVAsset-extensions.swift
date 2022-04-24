//
//  AVAsset-extensions.swift
//
//  Created by Joe Pagliaro on 10/5/17.
//  Copyright © 2017 Limit Point LLC. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos
import PhotosUI
import MobileCoreServices

extension AVAsset {
    
     func assetID() -> String? {
        
        let metadata = self.metadata(forFormat: .quickTimeMetadata)
        
        for item in metadata {
            let keyContentIdentifier =  "com.apple.quicktime.content.identifier"
            let keySpaceQuickTimeMetadata = "mdta"
            if item.key as? String == keyContentIdentifier &&
                item.keySpace!.rawValue == keySpaceQuickTimeMetadata {
                return item.value as? String
            }
        }
        return nil
        
    }
    
    open func convertMp4ToMov(completion: @escaping (_ outputURL: URL?) -> ()) -> Bool {
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let sourceVideoTrack = tracks(withMediaType: AVMediaType.video).first!
        let sourceAudioTrack = tracks(withMediaType: AVMediaType.audio).first
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: sourceVideoTrack, at: CMTime.zero)
            if let _sourceAudioTrack = sourceAudioTrack {
                try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: duration), of: _sourceAudioTrack, at: CMTime.zero)
            }
        } catch let error {
            print(error)
            completion(nil)
            return false
        }
        compositionVideoTrack?.preferredTransform = sourceVideoTrack.preferredTransform
        
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: composition)
        var preset: String = AVAssetExportPresetMediumQuality
        if compatiblePresets.contains(AVAssetExportPreset1920x1080) {
            preset = AVAssetExportPreset1920x1080
        }
        var isExporting = false
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: preset), exportSession.supportedFileTypes.contains(AVFileType.mp4) else {
            completion(nil)
            return false
        }
        
        let fileName = UUID().uuidString
        var dirURL = URL(
            fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true).appendingPathComponent("LivePhoto")
        if !FileManager.default.fileExists(atPath: dirURL.absoluteString) {
            try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
        }
        var outputURL = dirURL.appendingPathComponent(fileName).appendingPathExtension("mov")
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(atPath: outputURL.path)
            } catch _ as NSError {
            }
        }
        
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = AVFileType.mov
        isExporting = true
        exportSession.exportAsynchronously(completionHandler: {
            if exportSession.status == .completed && exportSession.error == nil {
                completion(outputURL)
            }
        })
        
        return isExporting
    }
    
    func audioAsset() throws -> AVAsset {
        
        let composition = AVMutableComposition()
        
        let audioTracks = tracks(withMediaType: AVMediaType.audio)
        
        for track in audioTracks {
            
            let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            } catch {
                throw error
            }
            compositionTrack?.preferredTransform = track.preferredTransform
        }
        return composition
    }
}
