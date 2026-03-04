//
//  VideoListCell.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import UIKit

protocol VideoListCellDelegate: AnyObject {
    func didTapDownloadButton(for video: Video)
}

class VideoListCell: UITableViewCell {
    
    weak var delegate: VideoListCellDelegate?
    private var video: Video?
    
    // UI Elements
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let downloadButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let thumbnailImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Configure thumbnail
        thumbnailImageView.backgroundColor = UIColor.lightGray
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        
        // Configure labels
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 1
        
        // Configure download button
        downloadButton.setTitle("Download", for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        downloadButton.layer.cornerRadius = 8
        downloadButton.backgroundColor = .systemBlue
        downloadButton.setTitleColor(.white, for: .normal)
        
        // Configure progress view
        progressView.isHidden = true
        progressView.progressTintColor = .systemBlue
        
        // Add subviews
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(downloadButton)
        contentView.addSubview(progressView)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Thumbnail
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -12),
            
            // Subtitle
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Download button
            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            downloadButton.widthAnchor.constraint(equalToConstant: 80),
            downloadButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Progress view
            progressView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: downloadButton.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 8),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func configure(with video: Video) {
        self.video = video
        
        titleLabel.text = video.title
        updateUI()
    }
    
    private func updateUI() {
        guard let video = video else { return }
        
        switch video.downloadStatusEnum {
        case .notDownloaded:
            downloadButton.setTitle("Download", for: .normal)
            downloadButton.backgroundColor = .systemBlue
            downloadButton.isEnabled = true
            progressView.isHidden = true
            subtitleLabel.text = "Tap to download"
            
        case .downloading:
            downloadButton.setTitle("Downloading", for: .normal)
            downloadButton.backgroundColor = .systemOrange
            downloadButton.isEnabled = true
            progressView.isHidden = false
            progressView.progress = video.downloadProgress
            let percentage = Int(video.downloadProgress * 100)
            subtitleLabel.text = "Downloading \(percentage)%"
            
        case .downloaded:
            downloadButton.setTitle("Downloaded", for: .normal)
            downloadButton.backgroundColor = .systemGreen
            downloadButton.isEnabled = true
            progressView.isHidden = true
            
            if let dateDownloaded = video.dateDownloaded {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                subtitleLabel.text = "Downloaded \(formatter.string(from: dateDownloaded))"
            } else {
                subtitleLabel.text = "Available offline"
            }
            
        case .paused:
            downloadButton.setTitle("Resume", for: .normal)
            downloadButton.backgroundColor = .systemBlue
            downloadButton.isEnabled = true
            progressView.isHidden = false
            progressView.progress = video.downloadProgress
            let percentage = Int(video.downloadProgress * 100)
            subtitleLabel.text = "Paused at \(percentage)%"
            
        case .failed:
            downloadButton.setTitle("Retry", for: .normal)
            downloadButton.backgroundColor = .systemRed
            downloadButton.isEnabled = true
            progressView.isHidden = true
            subtitleLabel.text = "Download failed"
        }
    }
    
    @objc private func downloadButtonTapped() {
        guard let video = video else { return }
        delegate?.didTapDownloadButton(for: video)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        video = nil
        progressView.progress = 0
        progressView.isHidden = true
    }
}
