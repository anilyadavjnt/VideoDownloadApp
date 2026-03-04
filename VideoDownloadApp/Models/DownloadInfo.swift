//
//  DownloadInfo.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import Foundation

struct DownloadInfo {
    let video: Video
    let task: URLSessionDownloadTask
    let startTime: Date
    
    init(video: Video, task: URLSessionDownloadTask) {
        self.video = video
        self.task = task
        self.startTime = Date()
    }
}
