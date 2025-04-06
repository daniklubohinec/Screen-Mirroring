import UIKit
import Photos
import SnapKit
import AVKit

enum MediaType {
    case photo
    case video
}
final class MediaViewController: BaseViewController {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private var playerView: PlayerView?
    private lazy var thumbnailCollectionView: UICollectionView = {
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
    private var asset: PHAsset
    private var mediaType: MediaType
    private var fetchResult: PHFetchResult<PHAsset>
    private var currentIndex: Int
    
    init(asset: PHAsset, mediaType: MediaType, fetchResult: PHFetchResult<PHAsset>, currentIndex: Int) {
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
        title = mediaType == .photo ? R.string.localizable.photo_Mirroring() : R.string.localizable.video_Mirroring()
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
    
    private func loadMedia() {
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

extension MediaViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        imageView.layer.borderColor = selected ? R.color.accentColor()?.cgColor : nil
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
