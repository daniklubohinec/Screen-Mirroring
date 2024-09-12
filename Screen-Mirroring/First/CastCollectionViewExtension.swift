//
//  FirstViewController.swift
//  Screen-Mirroring
//
//  Created by Liver Pauler on 08.01.24.
//

import Foundation
import UIKit

extension FirstViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellVideoCast = typeOfMirroringCollectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.videoCastId.identifier, for: indexPath) as? VideoCastCollectionViewCell
        else { return UICollectionViewCell.init() }
        guard let cellPhotoCast = typeOfMirroringCollectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCastId.identifier, for: indexPath) as? PhotoCastCollectionViewCell
        else { return UICollectionViewCell.init() }
        guard let cellWebCast = typeOfMirroringCollectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.webCastId.identifier, for: indexPath) as? WebCastCollectionViewCell
        else { return UICollectionViewCell.init() }
        guard let cellFilesCast = typeOfMirroringCollectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.filesCastId.identifier, for: indexPath) as? FilesCastCollectionViewCell
        else { return UICollectionViewCell.init() }
        
        switch indexPath.row {
        case 0:
            return cellVideoCast
        case 1:
            return cellPhotoCast
        case 2:
            return cellWebCast
        case 3:
            return cellFilesCast
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            cast(mediaType: .video)
        case 1:
            cast(mediaType: .photo)
        case 2:
            HapticGenerator.shared.generateImpact()
            let controller = WebViewController()
            navigationController?.pushViewController(controller, animated: true)
        case 3:
            HapticGenerator.shared.generateImpact()
            let vc = DocumentsPickerController(forOpeningContentTypes: [.pdf, .image, .video, .text, .data, .content, .compositeContent])
            vc.didPickDocument = { [weak self] in
                let controller = DocumentViewController(url: $0)
                self?.navigationController?.pushViewController(controller, animated: true)
            }
            present(vc, animated: true)
        default:
            break
        }
    }
}
