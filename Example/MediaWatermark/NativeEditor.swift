//
//  Merger.swift
//  MediaWatermarkExample
//
//  Created by MacUser2 on 2/20/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import AVKit

struct NativeEditor {
    enum NativeEditorError: Error {
        case emptyURL
        case overwrite
        case system
        case `default`(Error)
        case custom(String)
        
        var localizedDescription: String {
            switch self {
            case .emptyURL:
                return "Provide urls to process"
            case .overwrite:
                return "Failed to overwrite on previous file"
            case .system:
                return "System error. Failed to continue."
            case .default(let err):
                return err.localizedDescription
            case .custom(let str):
                return str
            }
        }
    }
    
    static func vStack(urls: [URL], _ completion: @escaping (Result<URL, NativeEditorError>) -> Void) {
        guard !urls.isEmpty else {
            completion(.failure(.emptyURL))
            return
        }
        
        // If there is only one video, we dont to touch it to save export time.
        if let url = urls.first, urls.count == 1 {
            completion(.success(url))
            return
        }
        
        let fileName = urls.first!.deletingPathExtension().lastPathComponent
        let fileExt = urls.first!.pathExtension
        
        let outputPath = NSTemporaryDirectory().appending("\(fileName)-merged.\(fileExt)")
        let outputURL = URL(fileURLWithPath: outputPath)
        
        if FileManager.default.fileExists(atPath: outputPath) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                completion(.failure(.overwrite))
                return
            }
        }
        
        var maxSize = CGSize(width: 1280.0, height: 720.0)
        var originY: CGFloat = 0
        
        let composition = AVMutableComposition()
        let instructions = AVMutableVideoCompositionInstruction()
        
        urls.enumerated().forEach { index, url in
            let asset = AVURLAsset(url: url)
            
            if index == 0 {
                maxSize = asset.tracks(withMediaType: .video).first!.naturalSize
                instructions.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            }
            
            let assetTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            let selectedTrack = asset.tracks(withMediaType: .video)[0]
            
            do {
                try assetTrack?.insertTimeRange(timeRange, of: selectedTrack, at: .zero)
            }
            catch {
                print(error)
                completion(.failure(.default(error)))
            }
            
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack!)
            layerInstruction.setTransform(CGAffineTransform(translationX: 0, y: originY), at: .zero)
            
            instructions.layerInstructions.append(layerInstruction)
            
            originY += maxSize.height
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [instructions]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = CGSize(width: maxSize.width, height: originY)
        
        guard let exporter = AVAssetExportSession(asset: composition,
                                                  presetName: AVAssetExportPresetHighestQuality) else {
                                                    completion(.failure(.system))
            return
        }
        
        exporter.outputURL = outputURL
        exporter.outputFileType = filetype(fileExt)
        exporter.videoComposition = videoComposition
        
        exporter.exportAsynchronously {
            if let error = exporter.error {
                completion(.failure(.default(error)))
            } else {
                completion(.success(exporter.outputURL!))
            }
        }
    }
    
    @available(iOS 11.0, *)
    private static func filetype(_ extStr: String) -> AVFileType {
        switch extStr.lowercased() {
        case "mov": return .mov
        case "mp4": return .mp4
        case "m4v": return .m4v
        case "m4a": return .m4a
        case "mobile3GPP": return .mobile3GPP
        case "mobile3GPP2": return .mobile3GPP2
        case "caf": return .caf
        case "wav": return .wav
        case "aiff": return .aiff
        case "aifc": return .aifc
        case "amr": return .amr
        case "mp3": return .mp3
        case "au": return .au
        case "ac3": return .ac3
        case "eac3": return .eac3
        case "jpg": return .jpg
        case "dng": return .dng
        case "heic": return .heic
        case "avci": return .avci
        case "heif": return .heif
        case "tif": return .tif
        default:
            fatalError("Convert file type for extension: \(self)")
        }
    }
}
