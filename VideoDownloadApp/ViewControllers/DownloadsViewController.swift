//
//  DownloadsViewController.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import UIKit

class DownloadsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var downloadedVideos: [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDownloadedVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDownloadedVideos()
    }
    
    private func setupUI() {
        title = "Downloads"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DownloadsCell.self, forCellReuseIdentifier: "DownloadsCell")
        
        // Add edit button
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    private func loadDownloadedVideos() {
        downloadedVideos = VideoDataManager.shared.fetchDownloadedVideos()
        tableView.reloadData()
        
        // Show empty state if no downloads
        if downloadedVideos.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No downloads yet"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = UIFont.systemFont(ofSize: 18)
        tableView.backgroundView = emptyLabel
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

// MARK: - UITableViewDataSource

extension DownloadsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadsCell", for: indexPath) as! DownloadsCell
        let video = downloadedVideos[indexPath.row]
        cell.configure(with: video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = downloadedVideos[indexPath.row]
            DownloadManager.shared.deleteDownloadedVideo(for: video)
            downloadedVideos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if downloadedVideos.isEmpty {
                showEmptyState()
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension DownloadsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = downloadedVideos[indexPath.row]
        let playerVC = VideoPlayerViewController()
        playerVC.video = video
        present(playerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
