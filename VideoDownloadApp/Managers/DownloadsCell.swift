//
//  DownloadsCell.swift
//  VideoDownloadApp
//
//  Created by Anil Yadav on 06/09/25.
//  Email: anilyadavjnt@gmail.com
//  Contact No: +91-975211420
//

import UIKit

class DownloadsCell: UITableViewCell {
    
    // UI Elements
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let fileSizeLabel = UILabel()
    private let thumbnailImageView = UIImageView()
    private let offlineIndicator = UIImageView()
    
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
        
        fileSizeLabel.font = UIFont.systemFont(ofSize: 12)
        fileSizeLabel.textColor = .systemBlue
        fileSizeLabel.textAlignment = .right
        
        // Configure offline indicator
        offlineIndicator.image = UIImage(systemName: "arrow.down.circle.fill")
        offlineIndicator.tintColor = .systemGreen
        
        // Add subviews
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(fileSizeLabel)
        contentView.addSubview(offlineIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        fileSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        offlineIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Thumbnail
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 70),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Offline indicator
            offlineIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            offlineIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            offlineIndicator.widthAnchor.constraint(equalToConstant: 20),
            offlineIndicator.heightAnchor.constraint(equalToConstant: 20),
            
            // Title
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: offlineIndicator.leadingAnchor, constant: -8),
            
            // Subtitle
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // File size
            fileSizeLabel.trailingAnchor.constraint(equalTo: offlineIndicator.trailingAnchor),
            fileSizeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            fileSizeLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with video: Video) {
        titleLabel.text = video.title
        
        if let dateDownloaded = video.dateDownloaded {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            subtitleLabel.text = "Downloaded \(formatter.string(from: dateDownloaded))"
        }
        
        // Format file size
        let fileSize = video.fileSize
        fileSizeLabel.text = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}
