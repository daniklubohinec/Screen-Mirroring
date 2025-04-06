//
//  FileUploaderViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import AVKit
import Photos
import SnapKit

final class FileUploaderViewController: StandartTypeViewController {
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var playerView: PlayerView?
    lazy var thumbnailCollectionView: UICollectionView = {
        // Thumbnail collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 0
        
        let thumbnailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        thumbnailCollectionView.dataSource = self
        thumbnailCollectionView.delegate = self
        thumbnailCollectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: "ThumbnailCell")
        thumbnailCollectionView.showsHorizontalScrollIndicator = false
        return thumbnailCollectionView
    }()
    var asset: PHAsset
    var mediaType: FileUploaderType
    var fetchResult: PHFetchResult<PHAsset>
    var currentIndex: Int
    
    init(asset: PHAsset, mediaType: FileUploaderType, fetchResult: PHFetchResult<PHAsset>, currentIndex: Int) {
        self.asset = asset
        self.mediaType = mediaType
        self.fetchResult = fetchResult
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadMedia()
        title = mediaType == .photo ? "Photo Mirroring" : "Video Mirroring"
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        // Main media view
        view.addSubview(containerView)
        view.addSubview(thumbnailCollectionView)
        containerView.snp.makeConstraints { make in
            make.leftMargin.equalToSuperview().offset(16)
            make.rightMargin.equalToSuperview().offset(-16)
            make.topMargin.equalToSuperview().offset(16)
            make.bottom.equalTo(thumbnailCollectionView.snp.top).offset(-24)
        }
        
        thumbnailCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-69)
            make.height.equalTo(80)
        }
        
        if mediaType == .video {
            playerView = PlayerView()
            containerView.addSubview(playerView!)
            playerView!.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            addChild(playerView!.playerViewController)
        }
    }
    
    func loadMedia() {
        switch mediaType {
        case .photo:
            loadPhoto()
        case .video:
            loadVideo()
        }
    }
    
    private func loadPhoto() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
    
    private func loadVideo() {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, _, _) in
            guard let avAsset = avAsset else { return }
            
            DispatchQueue.main.async {
                self?.playerView?.configure(with: avAsset)
            }
        }
    }
}

