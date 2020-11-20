//
//  Exporter.swift
//  HDR-Bug-Repro
//
//  Created by Josh Pyles on 11/19/20.
//

import Foundation
import Photos
import AVFoundation

class Exporter {
    
    var isNetworkAccessAllowed: Bool = true
    var exportPreset: String = AVAssetExportPreset960x540
    var outputFileType: AVFileType = .mov
    var shouldOptimizeForNetworkUse: Bool = true
    var deliveryMode: PHVideoRequestOptionsDeliveryMode = .automatic
    
    static let allPresets: [String] = [
        AVAssetExportPresetLowQuality,
        AVAssetExportPresetMediumQuality,
        AVAssetExportPresetHighestQuality,
        AVAssetExportPreset640x480,
        AVAssetExportPreset960x540,
        AVAssetExportPreset1280x720,
        AVAssetExportPreset1920x1080,
        AVAssetExportPreset3840x2160,
        AVAssetExportPresetHEVC1920x1080,
        AVAssetExportPresetHEVC3840x2160,
        AVAssetExportPresetHEVC1920x1080WithAlpha,
        AVAssetExportPresetHEVC3840x2160WithAlpha,
        AVAssetExportPresetHEVCHighestQuality,
        AVAssetExportPresetHEVCHighestQualityWithAlpha
    ]
    
    static let sharedInstance = Exporter()
    
    var preferredExtension: String {
        switch outputFileType {
        case .mp4:
            return "mp4"
        case .m4v:
            return "m4v"
        default:
            return "mov"
        }
    }
    
    func filename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy@hh:mm:ss"
        let now = Date()
        let dateString = dateFormatter.string(from: now)
        let presetString = Exporter.name(forPreset: exportPreset)
        return "\(presetString)-\(deliveryMode.filenameString)-\(shouldOptimizeForNetworkUse)-\(dateString).\(preferredExtension)"
    }
    
    static func name(forPreset presetName: String) -> String {
        switch presetName {
        case AVAssetExportPresetLowQuality:
            return "LowQuality-Broken"
        case AVAssetExportPresetMediumQuality:
            return "MediumQuality-Broken"
        case AVAssetExportPresetHighestQuality:
            return "HighestQuality"
        case AVAssetExportPreset640x480:
            return "640x480"
        case AVAssetExportPreset960x540:
            return "960x540-Broken"
        case AVAssetExportPreset1280x720:
            return "1280x720"
        case AVAssetExportPreset1920x1080:
            return "1920x1080"
        case AVAssetExportPreset3840x2160:
            return "3840x2160"
        case AVAssetExportPresetHEVC1920x1080:
            return "HEVC1920x1080"
        case AVAssetExportPresetHEVC3840x2160:
            return "HEVC3840x2160"
        case AVAssetExportPresetHEVC1920x1080WithAlpha:
            return "HEVC1920x1080WithAlpha"
        case AVAssetExportPresetHEVC3840x2160WithAlpha:
            return "HEVC3840x2160WithAlpha"
        case AVAssetExportPresetHEVCHighestQuality:
            return "HEVCHighestQuality"
        case AVAssetExportPresetHEVCHighestQualityWithAlpha:
            return "HEVCHighestQualityWithAlpha"
        default:
            return "Unknown"
        }
    }
    
    func export(assetIdentifier: String, to url: URL, completion: @escaping () -> Void) {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject else {
            completion()
            return
        }
        print("Exporting asset to \(url.relativePath)")
        let options = PHVideoRequestOptions()
        options.deliveryMode = deliveryMode
        options.isNetworkAccessAllowed = isNetworkAccessAllowed
        PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: exportPreset) { (exportSession, userInfo) in
            guard let exportSession = exportSession else {
                if let error = userInfo?[PHImageErrorKey] as? Error {
                    print(error)
                }
                completion()
                return
            }
            self.export(to: url, with: exportSession, completion: completion)
        }
    }
    
    private func export(to outputURL: URL, with exportSession: AVAssetExportSession, completion: @escaping () -> Void) {
        print("Exporting asset with session")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = outputFileType
        exportSession.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse
        exportSession.exportAsynchronously {
            self.didCompleteExport(to: outputURL, with: exportSession.status, error: exportSession.error, completion: completion)
        }
    }
    
    private func didCompleteExport(to outputURL: URL, with status: AVAssetExportSession.Status, error: Error?, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            switch status {
            case .completed:
                print("File exported to \(outputURL)")
            case .failed:
                print("Failed to export")
                if let error = error {
                    print("Error: \(error)")
                }
            case .cancelled:
                print("Export cancelled")
            default:
                print("Unknown error")
            }
            completion()
        }
    }
    
    
}

extension PHVideoRequestOptionsDeliveryMode {
    
    var filenameString: String {
        switch self {
        case .automatic:
            return "automatic"
        case .fastFormat:
            return "fast"
        case .mediumQualityFormat:
            return "medium"
        case .highQualityFormat:
            return "high"
        @unknown default:
            return "unknown"
        }
    }
    
}
