//
//  InAppGuideViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit

enum InAppGuideType {
    case lastStep
    case connect
    case disconnect
}

final class InAppGuideViewController: UIViewController {
    
    @IBOutlet private var containerView: UIView! {
        didSet {
            containerView.clipsToBounds = true
            containerView.layer.cornerRadius = 24.0
        }
    }
    
    @IBOutlet private var howToLabel: UILabel! {
        didSet {
            howToLabel.font = UIFont(name: "Inter-SemiBold", size: 22)
        }
    }
    
    @IBOutlet private var lastStepTitle: UILabel! {
        didSet {
            lastStepTitle.font = UIFont(name: "Inter-SemiBold", size: 22)
        }
    }
    
    @IBOutlet private var lastStepSubtitle: UILabel! {
        didSet {
            lastStepSubtitle.font = UIFont(name: "Inter-Regular", size: 15)
        }
    }
    
    @IBOutlet private var okButton: UIButton! {
        didSet {
            configureOkButton()
        }
    }
    
    @IBOutlet private var lastStepContainer: UIView!
    @IBOutlet private var lastStepImageContainer: UIView!
    @IBOutlet private var howToContainerView: UIView!
    @IBOutlet private var howToConnectFirstView: UIView!
    @IBOutlet private var howToConnectSecondView: UIView!
    @IBOutlet private var howToDisconnectView: UIView!
    
    var tipsType: InAppGuideType = .disconnect
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView(for: tipsType)
    }
    
    private func configureView(for tipsType: InAppGuideType) {
        switch tipsType {
        case .lastStep:
            lastStepContainer.isHidden = false
            lastStepImageContainer.isHidden = false
            howToContainerView.isHidden = true
        case .connect:
            lastStepContainer.isHidden = true
            lastStepImageContainer.isHidden = true
            howToDisconnectView.isHidden = true
            howToContainerView.isHidden = false
            howToLabel.text = "Tap to connect"
        case .disconnect:
            lastStepContainer.isHidden = true
            lastStepImageContainer.isHidden = true
            howToConnectFirstView.isHidden = true
            howToConnectSecondView.isHidden = true
            howToDisconnectView.isHidden = false
            howToContainerView.isHidden = false
            howToLabel.text = "How to Disconnect"
        }
    }
    
    private func configureOkButton() {
        okButton.titleLabel?.font = UIFont(name: "Inter-Medium", size: 18)
        okButton.clipsToBounds = true
        okButton.layer.cornerRadius = 16.0
        okButton.setTitleColor(.white, for: .normal)
        okButton.backgroundColor = UIColor(named: "c447AF8")
    }
    
    static func showActionSheet(tipsType: InAppGuideType, onViewController: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController) {
        guard let dialog = UIStoryboard(name: "InAppGuide", bundle: .main).instantiateViewController(identifier: "InAppGuideViewController") as? InAppGuideViewController else { return }
        
        dialog.modalPresentationStyle = .overFullScreen
        dialog.tipsType = tipsType
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let _ = delegate.window?.topViewController() as? InAppGuideViewController {
            return
        }
        
        onViewController?.firstInFlowViewController().present(dialog, animated: true)
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        hide(action: nil)
    }
    
    private func hide(action: (() -> Void)?) {
        modalTransitionStyle = .crossDissolve
        dismiss(animated: true, completion: action)
    }
}

