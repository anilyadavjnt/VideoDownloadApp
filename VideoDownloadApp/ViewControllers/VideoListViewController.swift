//
//  VideoListViewController.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import UIKit

class VideoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var videos: [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        loadSampleData()
    }
    
    private func setupUI() {
        title = "Videos"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VideoListCell.self, forCellReuseIdentifier: "VideoListCell")
        
        // Add Downloads tab bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Downloads",
            style: .plain,
            target: self,
            action: #selector(showDownloads)
        )
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(downloadProgressUpdated(_:)),
            name: .downloadProgressUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(downloadStatusChanged(_:)),
            name: .downloadCompleted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(downloadStatusChanged(_:)),
            name: .downloadFailed,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(downloadStatusChanged(_:)),
            name: .downloadStarted,
            object: nil
        )
    }
    
    private func loadSampleData() {
        // Create sample videos or load from your API
        let sampleVideos = [
            ("1", "Sample Video 1", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", ""),
            ("2", "Sample Video 2", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", ""),
            ("3", "Sample Video 3", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", "")
        ]
        
        for (id, title, url, thumbnail) in sampleVideos {
            if VideoDataManager.shared.fetchVideo(by: id) == nil {
                let video = VideoDataManager.shared.createVideo(id: id, title: title, videoURL: url, thumbnailURL: thumbnail)
                videos.append(video)
            } else {
                videos.append(VideoDataManager.shared.fetchVideo(by: id)!)
            }
        }
        
        tableView.reloadData()
    }
    
    @objc private func showDownloads() {
        let downloadsVC = DownloadsViewController()
        navigationController?.pushViewController(downloadsVC, animated: true)
    }
    
    @objc private func downloadProgressUpdated(_ notification: Notification) {
        guard let video = notification.object as? Video else { return }
        updateCellForVideo(video)
    }
    
    @objc private func downloadStatusChanged(_ notification: Notification) {
        guard let video = notification.object as? Video else { return }
        updateCellForVideo(video)
    }
    
    private func updateCellForVideo(_ video: Video) {
        guard let videoId = video.id,
              let index = videos.firstIndex(where: { $0.id == videoId }) else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? VideoListCell {
            cell.configure(with: video)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource

extension VideoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell", for: indexPath) as! VideoListCell
        let video = videos[indexPath.row]
        cell.configure(with: video)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension VideoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = videos[indexPath.row]
        let playerVC = VideoPlayerViewController()
        playerVC.video = video
        present(playerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - VideoListCellDelegate

extension VideoListViewController: VideoListCellDelegate {
    
    func didTapDownloadButton(for video: Video) {
        switch video.downloadStatusEnum {
        case .notDownloaded:
            DownloadManager.shared.startDownload(for: video)
        case .downloading:
            // Show options to pause/cancel
            showDownloadOptions(for: video)
        case .downloaded:
            // Show options to delete
            showDeleteOption(for: video)
        case .paused:
            DownloadManager.shared.resumeDownload(for: video)
        case .failed:
            DownloadManager.shared.startDownload(for: video)
        }
    }
    
    private func showDownloadOptions(for video: Video) {
        let alert = UIAlertController(title: "Download Options", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Pause", style: .default) { _ in
            DownloadManager.shared.pauseDownload(for: video)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) { _ in
            DownloadManager.shared.cancelDownload(for: video)
        })
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showDeleteOption(for video: Video) {
        let alert = UIAlertController(title: "Delete Download", message: "Are you sure you want to delete this downloaded video?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            DownloadManager.shared.deleteDownloadedVideo(for: video)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}
