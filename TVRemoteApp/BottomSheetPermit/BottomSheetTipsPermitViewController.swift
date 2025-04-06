//
//  BottomSheetTipsPermitViewController.swift
//  QR-Reader
//
//  Created by Liver Pauler on 08.01.24.
//

import UIKit
import RxSwift

class BottomSheetTipsPermitViewController: UIViewController {
    
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var interfaceBackView: UIView!
    
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // public
    public var mainImageView: UIImage? = UIImage(named: "")
    public var titleText: String = ""
    public var subtitleText: String = ""
    public var firstAction: (action: () -> Void, image: UIImage?, title: String) = ({}, UIImage(named: ""), "")
    
    // private
    private let disposeBag = DisposeBag()
    
    private var firstActionPrivate: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        background.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        // set image
        mainImage.image = mainImageView
        
        // set title's
        titleLabel.text = titleText
        subtitleLabel.text = subtitleText
        
        // set actions
        firstActionPrivate = firstAction.action
        
        // set button image
        firstButton.setImage(firstAction.image, for: .normal)
        
        // set tittles
        firstButton.setTitle(firstAction.title, for: .normal)
        
        firstButton.titleEdgeInsets.left = firstAction.image == nil ? 0 : 8
        firstButton.imageEdgeInsets.right = firstAction.image == nil ? 0 : 8
        
        // handle first action
        firstButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                HapticGenerator.shared.generateImpact()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    strongSelf.hide(action: strongSelf.firstActionPrivate)
                }
            })
            .disposed(by: disposeBag)
        
        // handle cancel action
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                HapticGenerator.shared.generateImpact()
                strongSelf.hide(action: nil)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.background.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    static func showActionSheet(
        mainImage: UIImage?,
        titleText: String,
        subtitleText: String,
        firstAction: (action: () -> Void, image: UIImage?, title: String),
        onViewController: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController) {
            
            guard let dialog = R.storyboard.actionSheet.actionSheetViewController() else { return }
            
            dialog.modalPresentationStyle = .overFullScreen
            dialog.mainImageView = mainImage
            dialog.titleText = titleText
            dialog.subtitleText = subtitleText
            dialog.firstAction = firstAction
            
            if let delegate = UIApplication.shared.delegate as? AppDelegate,
               let _ = delegate.window?.topViewController() as? BottomSheetTipsPermitViewController { } else {
                   onViewController?.topViewController().present(dialog, animated: true)
               }
        }
    
    private func hide(_ success: Bool = false, action: (() -> Void)?) {
        modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true, completion: {
            guard let action = action else { return }
            action()
        })
    }
    
    private func action(_ success: Bool = false, action: (() -> Void)?) {
        guard let action = action else { return }
        action()
    }
    
    @IBAction
    private func close(_ sender: Any) {
        HapticGenerator.shared.generateImpact()
        hide(action: nil)
    }
}
