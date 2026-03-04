//
//  DownloadManager.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import Foundation
import UIKit

class DownloadManager: NSObject {
    
    static let shared = DownloadManager()
    
    private var backgroundSession: URLSession!
    private var activeDownloads: [String: DownloadInfo] = [:]
    private var backgroundCompletionHandler: (() -> Void)?
    
    private override init() {
        super.init()
        setupBackgroundSession()
    }
    
    // MARK: - Setup
    
    private func setupBackgroundSession() {
        let config = URLSessionConfiguration.background(withIdentifier: Constants.backgroundDownloadIdentifier)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        
        backgroundSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Public Methods
    
    func startDownload(for video: Video) {
        guard let videoId = video.id,
              let urlString = video.videoURL,
              let url = URL(string: urlString),
              activeDownloads[videoId] == nil else {
            print("Invalid video data or download already in progress")
            return
        }
        
        // Check if already downloaded
        if FileManager.videoExists(for: videoId) {
            VideoDataManager.shared.updateVideoDownloadStatus(video, status: .downloaded)
            return
        }
        
        // Limit concurrent downloads
        if activeDownloads.count >= Constants.maxConcurrentDownloads {
            print("Maximum concurrent downloads reached")
            return
        }
        
        let downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.taskDescription = videoId
        
        let downloadInfo = DownloadInfo(video: video, task: downloadTask)
        activeDownloads[videoId] = downloadInfo
        
        VideoDataManager.shared.updateVideoDownloadStatus(video, status: .downloading)
        downloadTask.resume()
        
        // Post notification
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .downloadStarted, object: video)
        }
        
        print("Started download for video: \(video.title ?? "Unknown")")
    }
    
    func pauseDownload(for video: Video) {
        guard let videoId = video.id,
              let downloadInfo = activeDownloads[videoId] else { return }
        
        downloadInfo.task.suspend()
        VideoDataManager.shared.updateVideoDownloadStatus(video, status: .paused)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .downloadPaused, object: video)
        }
    }
    
    func resumeDownload(for video: Video) {
        guard let videoId = video.id,
              let downloadInfo = activeDownloads[videoId] else { return }
        
        downloadInfo.task.resume()
        VideoDataManager.shared.updateVideoDownloadStatus(video, status: .downloading)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .downloadResumed, object: video)
        }
    }
    
    func cancelDownload(for video: Video) {
        guard let videoId = video.id,
              let downloadInfo = activeDownloads[videoId] else { return }
        
        downloadInfo.task.cancel()
        activeDownloads.removeValue(forKey: videoId)
        VideoDataManager.shared.updateVideoDownloadStatus(video, status: .notDownloaded, progress: 0.0)
        
        // Clean up any partial files
        try? FileManager.deleteVideo(for: videoId)
    }
    
    func deleteDownloadedVideo(for video: Video) {
        guard let videoId = video.id else { return }
        
        // Cancel if currently downloading
        if activeDownloads[videoId] != nil {
            cancelDownload(for: video)
        }
        
        // Delete file and update database
        try? FileManager.deleteVideo(for: videoId)
        VideoDataManager.shared.updateVideoDownloadStatus(video, status: .notDownloaded, progress: 0.0)
        video.localVideoPath = nil
        video.dateDownloaded = nil
        video.fileSize = 0
        VideoDataManager.shared.saveContext()
    }
    
    func isDownloading(_ video: Video) -> Bool {
        guard let videoId = video.id else { return false }
        return activeDownloads[videoId] != nil
    }
    
    func setBackgroundCompletionHandler(_ handler: @escaping () -> Void) {
        backgroundCompletionHandler = handler
    }
    
    // MARK: - Private Methods
    
    private func moveDownloadedFile(from location: URL, to destination: URL) throws {
        // Create destination directory if needed
        let destinationDirectory = destination.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: destinationDirectory.path) {
            try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: [
                FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
            ])
        }
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        
        // Move file with data protection
        try FileManager.default.moveItem(at: location, to: destination)
        
        // Set file protection
        try FileManager.default.setAttributes([
            FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
        ], ofItemAtPath: destination.path)
    }
}

// MARK: - URLSessionDownloadDelegate

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let videoId = downloadTask.taskDescription,
              let downloadInfo = activeDownloads[videoId] else {
            print("No active download found for completed task")
            return
        }
        
        let video = downloadInfo.video
        let destinationURL = FileManager.localVideoURL(for: videoId)
        
        do {
            try moveDownloadedFile(from: location, to: destinationURL)
            
            DispatchQueue.main.async {
                VideoDataManager.shared.updateVideoDownloadStatus(video, status: .downloaded, progress: 1.0)
                self.activeDownloads.removeValue(forKey: videoId)
                
                NotificationCenter.default.post(name: .downloadCompleted, object: video)
            }
            
            print("Successfully downloaded video: \(video.title ?? "Unknown")")
            
        } catch {
            print("Error moving downloaded file: \(error)")
            
            DispatchQueue.main.async {
                VideoDataManager.shared.updateVideoDownloadStatus(video, status: .failed)
                self.activeDownloads.removeValue(forKey: videoId)
                
                NotificationCenter.default.post(name: .downloadFailed, object: video, userInfo: ["error": error])
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let videoId = downloadTask.taskDescription,
              let downloadInfo = activeDownloads[videoId],
              totalBytesExpectedToWrite > 0 else { return }
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let video = downloadInfo.video
        
        DispatchQueue.main.async {
            VideoDataManager.shared.updateVideoDownloadStatus(video, status: .downloading, progress: progress)
            
            NotificationCenter.default.post(name: .downloadProgressUpdated, object: video, userInfo: [
                "progress": progress,
                "bytesWritten": totalBytesWritten,
                "totalBytes": totalBytesExpectedToWrite
            ])
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let videoId = task.taskDescription,
              let downloadInfo = activeDownloads[videoId] else { return }
        
        if let error = error {
            let video = downloadInfo.video
            
            DispatchQueue.main.async {
                VideoDataManager.shared.updateVideoDownloadStatus(video, status: .failed)
                self.activeDownloads.removeValue(forKey: videoId)
                
                NotificationCenter.default.post(name: .downloadFailed, object: video, userInfo: ["error": error])
            }
            
            print("Download failed for video \(video.title ?? "Unknown"): \(error.localizedDescription)")
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}
