//
//  VideoUploader.swift
//  XClone
//
//  Created by Stephan Dowless on 2/26/25.
//

import AVKit
import FirebaseStorage
import UIKit

struct VideoService {
    func uploadVideoToStorage(withUrl url: URL) async throws -> String? {
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/post_videos/").child(filename)
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        do {
            let data = try Data(contentsOf: url)
            _ = try await ref.putDataAsync(data, metadata: metadata)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload video with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func generateThumbnail(path: String) -> UIImage? {
        do {
            guard let url = URL(string: path) else { return nil }
            let asset = AVURLAsset(url: url, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("DEBUG: Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
