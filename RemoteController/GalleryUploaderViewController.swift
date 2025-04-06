//
//  GalleryUploaderViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import Photos

final class GalleryUploaderViewController: StandartTypeViewController {
    
    private let album: PHAssetCollection
    let mediaType: FileUploaderType
    var assets: PHFetchResult<PHAsset>!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemSize = (view.bounds.width / 3) - 2
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GalleryUploaderCell.self, forCellWithReuseIdentifier: GalleryUploaderCell.reuseIdentifier)
        return collectionView
    }()
    
    init(album: PHAssetCollection, mediaType: FileUploaderType) {
        self.album = album
        self.mediaType = mediaType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = mediaType == .photo ? "Photo Mirroring" : "Video Mirroring"
        
        setupViews()
        fetchMedia()
    }
    
    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func fetchMedia() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d",
                                             mediaType == .photo ? PHAssetMediaType.image.rawValue : PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        collectionView.reloadData()
    }
}

