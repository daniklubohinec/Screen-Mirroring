import UIKit
import Photos
import SnapKit
import RxSwift
import RxCocoa

final class AlbumViewController: BaseViewController {
    private let collectionView: UICollectionView
    private let disposeBag = DisposeBag()
    private let albums = BehaviorRelay<[PHAssetCollection]>(value: [])
    private var mediaType: MediaType
    
    init(mediaType: MediaType) {
        self.mediaType = mediaType
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 32) / 2 - 16, height: 219)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = .init(top: 16, left: 16, bottom: 0, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "AlbumCell")
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        setupViews()
        setupNavigationBar()
        bindCollectionView()
        requestPhotoLibraryAccess()
    }
    
    private func setupNavigationBar() {
        title = mediaType == .photo ? R.string.localizable.photo_Mirroring() : R.string.localizable.video_Mirroring()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupViews() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .black
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindCollectionView() {
        let mediaType = self.mediaType
        albums
            .bind(to: collectionView.rx.items(cellIdentifier: "AlbumCell", cellType: AlbumCell.self)) { _, album, cell in
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1
                switch mediaType {
                case .photo:
                    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
                case .video:
                    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
                }

                let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
                if let firstAsset = assets.lastObject {
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .highQualityFormat
                    options.resizeMode = .exact
                    options.isNetworkAccessAllowed = true
                    PHImageManager.default().requestImage(for: firstAsset, targetSize: CGSize(width: 171, height: 171), contentMode: .aspectFill, options: options) { image, _ in
                        let album = Album(title: album.localizedTitle ?? "", image: image)
                        cell.configure(with: album)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let album = self.albums.value[indexPath.item]
                let photosVC = PhotosViewController(album: album, mediaType: mediaType)
                self.navigationController?.pushViewController(photosVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func requestPhotoLibraryAccess() {
        fetchAlbums()
    }
    
    private func fetchAlbums() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        var albumsArray: [PHAssetCollection] = []
        
        userAlbums.enumerateObjects { (collection, _, _) in
            let assetsFetchResult = self.fetchAssetsFromCollection(collection)
            if assetsFetchResult.count > 0 {
                albumsArray.append(collection)
            }
        }
        
        DispatchQueue.main.async {
            self.albums.accept(albumsArray)
        }
    }
    
    private func fetchAssetsFromCollection(_ collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        switch mediaType {
        case .photo:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        case .video:
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        }
        return PHAsset.fetchAssets(in: collection, options: fetchOptions)
    }
}
struct Album {
    let title: String
    let image: UIImage?
}

final class AlbumCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    private var album: Album?
    
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
        imageView.layer.cornerRadius = 8.0
        titleLabel.textColor = .white
        titleLabel.font = R.font.interBold(size: 16)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func configure(with album: Album) {
        self.album = album
        titleLabel.text = album.title
        imageView.image = album.image
    }
}
