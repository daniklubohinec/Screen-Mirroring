//
//  MirrorTypeCell.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit

// MARK: - Album Model
struct MirrorType {
    let title: String
    let image: UIImage?
}

// MARK: - AlbumCell
final class MirrorTypeCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AlbumCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setupImageView()
        setupTitleLabel()
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8.0
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Inter-Bold", size: 16)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func configure(with album: MirrorType) {
        titleLabel.text = album.title
        imageView.image = album.image
    }
}
