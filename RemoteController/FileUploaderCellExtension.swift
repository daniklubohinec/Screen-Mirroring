//
//  FileUploaderCellExtension.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import AVKit
import Photos

enum FileUploaderType {
    case photo
    case video
}

extension FileUploaderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        let asset = fetchResult.object(at: indexPath.item)
        cell.configure(with: asset, selected: currentIndex == indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.item
        asset = fetchResult.object(at: currentIndex)
        loadMedia()
        collectionView.reloadData()
    }
}

final class ThumbnailCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14.0
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with asset: PHAsset, selected: Bool) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: options) { [weak self] image, _ in
            self?.imageView.image = image
        }
        imageView.layer.borderWidth = selected ? 2.0 : 0.0
        imageView.layer.borderColor = selected ? UIColor(named: "c447AF8")?.cgColor : nil
    }
}

final class PlayerView: UIView {
    var playerViewController: AVPlayerViewController
    
    override init(frame: CGRect) {
        self.playerViewController = AVPlayerViewController()
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        self.playerViewController = AVPlayerViewController()
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(playerViewController.view)
        playerViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playerViewController.showsPlaybackControls = true
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.showsTimecodes = true
    }
    
    func configure(with asset: AVAsset) {
        let playerItem = AVPlayerItem(asset: asset)
        playerViewController.player = AVPlayer(playerItem: playerItem)
        
    }
}

