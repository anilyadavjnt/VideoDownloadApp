//
//  NotificationNames.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import Foundation

extension Notification.Name {
    static let downloadProgressUpdated = Notification.Name("downloadProgressUpdated")
    static let downloadCompleted = Notification.Name("downloadCompleted")
    static let downloadFailed = Notification.Name("downloadFailed")
    static let downloadStarted = Notification.Name("downloadStarted")
    static let downloadPaused = Notification.Name("downloadPaused")
    static let downloadResumed = Notification.Name("downloadResumed")
}
