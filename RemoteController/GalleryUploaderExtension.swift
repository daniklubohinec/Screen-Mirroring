//
//  GalleryUploaderExtension.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import Photos

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension GalleryUploaderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryUploaderCell.reuseIdentifier, for: indexPath) as? GalleryUploaderCell,
              assets.count > indexPath.item else {
            return UICollectionViewCell()
        }
        
        let asset = assets[indexPath.item]
        loadThumbnail(for: asset, into: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard assets.count > indexPath.item else { return }
        
        let asset = assets[indexPath.item]
        let index = assets.index(of: asset)
        let mediaVC = FileUploaderViewController(asset: asset, mediaType: mediaType, fetchResult: assets, currentIndex: index)
        navigationController?.pushViewController(mediaVC, animated: true)
    }
    
    private func loadThumbnail(for asset: PHAsset, into cell: GalleryUploaderCell) {
        let thumbnailSize = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: options) { image, _ in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
    }
}

// MARK: - PhotoCell

final class GalleryUploaderCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotoCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

