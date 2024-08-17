import Foundation
import UIKit
import Photos

final class PhotosViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var collectionView: UICollectionView!
    private var album: PHAssetCollection
    private var assets: PHFetchResult<PHAsset>!
    private var mediaType: MediaType
    
    init(album: PHAssetCollection, mediaType: MediaType) {
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
        setupCollectionView()
        fetchMedia()
        title = mediaType == .photo ? "Photo Mirroring" : "Video Mirroring"
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width / 3 - 2, height: view.bounds.width / 3 - 2)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        view.addSubview(collectionView)
    }
    
    private func fetchMedia() {
        let fetchOptions = PHFetchOptions()
        switch mediaType {
        case .photo:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        case .video:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        }
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let asset = assets[indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) { image, _ in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        let index = assets.index(of: asset)
        let photoVC = MediaViewController(asset: asset, mediaType: mediaType, fetchResult: assets, currentIndex: index)
        navigationController?.pushViewController(photoVC, animated: true)
    }
}

final class PhotoCell: UICollectionViewCell {
    let imageView = UIImageView()
    
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
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
