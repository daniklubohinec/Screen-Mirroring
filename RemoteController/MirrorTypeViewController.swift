//
//  MirrorTypeViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import Photos
import SnapKit
import RxSwift
import RxCocoa

final class MirrorTypeViewController: StandartTypeViewController {
    
    private let collectionView: UICollectionView
    private let disposeBag = DisposeBag()
    private let albums = BehaviorRelay<[PHAssetCollection]>(value: [])
    private let mediaType: FileUploaderType
    
    init(mediaType: FileUploaderType) {
        self.mediaType = mediaType
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 48) / 2, height: 219)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
        
        collectionView.register(MirrorTypeCell.self, forCellWithReuseIdentifier: MirrorTypeCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        setupBindings()
        fetchAlbums()
    }
    
    private func configureView() {
        view.backgroundColor = .black
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        title = mediaType == .photo ? "Photo Mirroring" : "Video Mirroring"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .black
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func setupBindings() {
        albums
            .bind(to: collectionView.rx.items(cellIdentifier: MirrorTypeCell.reuseIdentifier, cellType: MirrorTypeCell.self)) { [weak self] _, album, cell in
                self?.loadAlbumThumbnail(for: album, into: cell)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.navigateToPhotos(for: indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    private func loadAlbumThumbnail(for album: PHAssetCollection, into cell: MirrorTypeCell) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", mediaTypePredicateValue)
        
        if let firstAsset = PHAsset.fetchAssets(in: album, options: fetchOptions).lastObject {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestImage(
                for: firstAsset,
                targetSize: CGSize(width: 171, height: 171),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                cell.configure(with: MirrorType(title: album.localizedTitle ?? "", image: image))
            }
        }
    }
    
    private func navigateToPhotos(for indexPath: IndexPath) {
        let selectedAlbum = albums.value[indexPath.item]
        let photosVC = GalleryUploaderViewController(album: selectedAlbum, mediaType: mediaType)
        navigationController?.pushViewController(photosVC, animated: true)
    }
    
    private func fetchAlbums() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        var albumList: [PHAssetCollection] = []
        
        userAlbums.enumerateObjects { [weak self] collection, _, _ in
            guard let self = self else { return }
            if self.hasMedia(in: collection) {
                albumList.append(collection)
            }
        }
        
        DispatchQueue.main.async {
            self.albums.accept(albumList)
        }
    }
    
    private func hasMedia(in collection: PHAssetCollection) -> Bool {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", mediaTypePredicateValue)
        return PHAsset.fetchAssets(in: collection, options: fetchOptions).count > 0
    }
    
    private var mediaTypePredicateValue: Int {
        mediaType == .photo ? PHAssetMediaType.image.rawValue : PHAssetMediaType.video.rawValue
    }
}

