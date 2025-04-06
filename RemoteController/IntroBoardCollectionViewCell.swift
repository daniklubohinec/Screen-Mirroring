//
//  IntroBoardCollectionViewCell.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit

class IntroBoardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var introBoardImageView: UIImageView!
    @IBOutlet weak var introBoardTitleText: UILabel!
    @IBOutlet weak var introBoardSubtitleText: UILabel!
    
    func configureCell(boardScreen: IntroBoardStructure) {
        self.introBoardImageView.image = UIImage(named: boardScreen.imageView)
        self.introBoardTitleText.text = boardScreen.titleLabel
        self.introBoardSubtitleText.text = boardScreen.subtitleLabel
    }
}
