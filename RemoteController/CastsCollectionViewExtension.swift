//
//  CastsCollectionViewExtension.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import AVKit

extension OnFlowCastsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - Enum for Mirroring Types
    private enum MediaType: Int, CaseIterable {
        case video, photo, web, files
        
        var cellIdentifier: String {
            switch self {
            case .video: return "videoCastId"
            case .photo: return "photoCastId"
            case .web: return "webCastId"
            case .files: return "filesCastId"
            }
        }
        
        func performAction(in viewController: OnFlowCastsViewController) {
            switch self {
            case .video:
                viewController.cast(mediaType: .video)
            case .photo:
                viewController.cast(mediaType: .photo)
            case .web:
                EfficinacyCaller.shared.callHaptic()
                let controller = WKMirroringViewController()
                viewController.navigationController?.pushViewController(controller, animated: true)
            case .files:
                EfficinacyCaller.shared.callHaptic()
                let picker = DocFilesUploaderPickerController(forOpeningContentTypes: [.pdf, .image, .video, .text, .data, .content, .compositeContent])
                picker.didPickDocument = { [weak viewController] url in
                    let controller = DocFilesUploaderViewController(url: url)
                    viewController?.navigationController?.pushViewController(controller, animated: true)
                }
                viewController.present(picker, animated: true)
            }
        }
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MediaType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mediaType = MediaType(rawValue: indexPath.row) else {
            return UICollectionViewCell()
        }
        return dequeueCell(for: mediaType, at: indexPath)
    }
    
    private func dequeueCell(for mediaType: MediaType, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = typeOfMirroringCollectionView.dequeueReusableCell(withReuseIdentifier: mediaType.cellIdentifier, for: indexPath)
        
        // Ensure correct cell type
        switch mediaType {
        case .video: return cell as? VideoCastCollectionViewCell ?? UICollectionViewCell()
        case .photo: return cell as? PhotoCastCollectionViewCell ?? UICollectionViewCell()
        case .web: return cell as? WebCastCollectionViewCell ?? UICollectionViewCell()
        case .files: return cell as? FilesCastCollectionViewCell ?? UICollectionViewCell()
        }
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mediaType = MediaType(rawValue: indexPath.row) else { return }
        mediaType.performAction(in: self)
    }
}

extension AVRoutePickerView {
    func showAirplayView() {
        for view in subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
    }
}
