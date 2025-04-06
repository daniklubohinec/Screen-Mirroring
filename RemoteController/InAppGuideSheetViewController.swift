//
//  InAppGuideSheetViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import RxSwift
import RxCocoa

final class InAppGuideSheetViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var background: UIView!
    @IBOutlet private weak var interfaceBackView: UIView!
    @IBOutlet private weak var mainImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    
    // MARK: - Properties
    public var mainImageView: UIImage?
    public var titleText: String = ""
    public var subtitleText: String = ""
    public var firstAction: (action: () -> Void, image: UIImage?, title: String) = ({}, nil, "")
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupButtonActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateBackground(visible: true)
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        background.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        // Configure image & labels
        mainImage.image = mainImageView
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
        
        // Configure button
        firstButton.setImage(firstAction.image, for: .normal)
        firstButton.setTitle(firstAction.title, for: .normal)
        
        let hasImage = firstAction.image != nil
        firstButton.titleEdgeInsets.left = hasImage ? 8 : 0
        firstButton.imageEdgeInsets.right = hasImage ? 8 : 0
    }
    
    private func setupButtonActions() {
        firstButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleButtonTap(action: self?.firstAction.action)
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleButtonTap(action: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleButtonTap(action: (() -> Void)?) {
        EfficinacyCaller.shared.callHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.hide(action: action)
        }
    }
    
    private func animateBackground(visible: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.background.backgroundColor = UIColor.black.withAlphaComponent(visible ? 0.5 : 0.0)
        }
    }
    
    // MARK: - Presentation Method
    static func showActionSheet(
        mainImage: UIImage?,
        titleText: String,
        subtitleText: String,
        firstAction: (action: () -> Void, image: UIImage?, title: String),
        onViewController: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
    ) {
        guard let dialog = UIStoryboard(name: "InAppGuide", bundle: .main)
            .instantiateViewController(identifier: "ActionSheetViewController") as? InAppGuideSheetViewController else {
            return
        }
        
        dialog.modalPresentationStyle = .overFullScreen
        dialog.mainImageView = mainImage
        dialog.titleText = titleText
        dialog.subtitleText = subtitleText
        dialog.firstAction = firstAction
        
        if let topVC = onViewController?.firstInFlowViewController(), !(topVC is InAppGuideSheetViewController) {
            topVC.present(dialog, animated: true)
        }
    }
    
    // MARK: - Dismissal
    private func hide(action: (() -> Void)?) {
        modalTransitionStyle = .crossDissolve
        dismiss(animated: true) {
            action?()
        }
    }
    
    @IBAction private func closeTapped(_ sender: Any) {
        EfficinacyCaller.shared.callHaptic()
        hide(action: nil)
    }
}
