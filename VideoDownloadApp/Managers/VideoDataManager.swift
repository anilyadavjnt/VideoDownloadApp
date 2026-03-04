//
//  VideoDataManager.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import Foundation
import CoreData

class VideoDataManager {
    
    static let shared = VideoDataManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VideoDownloadApp")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Video CRUD operations
    
    func createVideo(id: String, title: String, videoURL: String, thumbnailURL: String) -> Video {
        let video = Video(context: context)
        video.id = id
        video.title = title
        video.videoURL = videoURL
        video.thumbnailURL = thumbnailURL
        video.downloadStatusEnum = .notDownloaded
        video.downloadProgress = 0.0
        video.fileSize = 0
        
        saveContext()
        return video
    }
    
    func fetchVideo(by id: String) -> Video? {
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let videos = try context.fetch(request)
            return videos.first
        } catch {
            print("Error fetching video: \(error)")
            return nil
        }
    }
    
    func fetchAllVideos() -> [Video] {
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching videos: \(error)")
            return []
        }
    }
    
    func fetchDownloadedVideos() -> [Video] {
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.predicate = NSPredicate(format: "downloadStatus == %@", Video.DownloadStatus.downloaded.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "dateDownloaded", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching downloaded videos: \(error)")
            return []
        }
    }
    
    func updateVideoDownloadStatus(_ video: Video, status: Video.DownloadStatus, progress: Float = 0.0) {
        video.downloadStatusEnum = status
        video.downloadProgress = progress
        
        if status == .downloaded {
            video.dateDownloaded = Date()
            if let videoId = video.id {
                video.fileSize = FileManager.getVideoFileSize(for: videoId)
                video.localVideoPath = FileManager.localVideoURL(for: videoId).path
            }
        }
        
        saveContext()
    }
    
    func deleteVideo(_ video: Video) {
        if let videoId = video.id {
            try? FileManager.deleteVideo(for: videoId)
        }
        context.delete(video)
        saveContext()
    }
}
