//
//  Video.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import Foundation
import CoreData

@objc(Video)
public class Video: NSManagedObject {

    enum DownloadStatus: String, CaseIterable {
        case notDownloaded = "not_downloaded"
        case downloading = "downloading"
        case downloaded = "downloaded"
        case failed = "failed"
        case paused = "paused"
    }

    var downloadStatusEnum: DownloadStatus {
        get {
            return DownloadStatus(rawValue: downloadStatus ?? "not_downloaded") ?? .notDownloaded
        }
        set {
            downloadStatus = newValue.rawValue
        }
    }
}

extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var videoURL: String?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var localVideoPath: String?
    @NSManaged public var downloadStatus: String?
    @NSManaged public var downloadProgress: Float
    @NSManaged public var fileSize: Int64
    @NSManaged public var dateDownloaded: Date?
}
