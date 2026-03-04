//
//  VideoPlayerViewController.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: AVPlayerViewController {
    
    var video: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
    }
    
    private func setupPlayer() {
        guard let video = video else { return }
        
        var videoURL: URL?
        
        // Check if video is downloaded locally
        if let videoId = video.id, FileManager.videoExists(for: videoId) {
            videoURL = FileManager.localVideoURL(for: videoId)
            print("Playing downloaded video from: \(videoURL?.path ?? "")")
        } else if let urlString = video.videoURL {
            videoURL = URL(string: urlString)
            print("Streaming video from: \(urlString)")
        }
        
        guard let url = videoURL else {
            showError("Unable to load video")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Add observer for playback status
        player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        // Add close button
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closePlayer))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func closePlayer() {
        dismiss(animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.status == .failed {
                showError("Failed to load video")
            }
        }
    }
    
    deinit {
        player?.removeObserver(self, forKeyPath: "status")
    }
}
