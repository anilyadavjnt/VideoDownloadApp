//
//  FileManager+Extensions.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import Foundation

extension FileManager {
    
    static var documentsVideoDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoDirectory = documentsPath.appendingPathComponent(Constants.documentsVideoFolder)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: videoDirectory.path) {
            try? FileManager.default.createDirectory(at: videoDirectory, withIntermediateDirectories: true, attributes: [
                FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
            ])
        }
        
        return videoDirectory
    }
    
    static func localVideoURL(for videoId: String) -> URL {
        return documentsVideoDirectory.appendingPathComponent("\(videoId).mp4")
    }
    
    static func videoExists(for videoId: String) -> Bool {
        let localURL = localVideoURL(for: videoId)
        return FileManager.default.fileExists(atPath: localURL.path)
    }
    
    static func deleteVideo(for videoId: String) throws {
        let localURL = localVideoURL(for: videoId)
        if FileManager.default.fileExists(atPath: localURL.path) {
            try FileManager.default.removeItem(at: localURL)
        }
    }
    
    static func getVideoFileSize(for videoId: String) -> Int64 {
        let localURL = localVideoURL(for: videoId)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
}
