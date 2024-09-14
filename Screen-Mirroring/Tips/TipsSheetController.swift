import Foundation
import UIKit
import RxSwift

enum TipsType {
    case lastStep
    case connect
    case disconnect
}

final class TipsSheetController: UIViewController {
    @IBOutlet private var containerView: UIView! {
        didSet {
            containerView.clipsToBounds = true
            containerView.layer.cornerRadius = 24.0
        }
    }
    @IBOutlet private var howToLabel: UILabel! {
        didSet {
            howToLabel.font = R.font.interSemiBold(size: 22.0)
        }
    }
    @IBOutlet private var lastStepTitle: UILabel! {
        didSet {
            lastStepTitle.font = R.font.interSemiBold(size: 22.0)
        }
    }
    @IBOutlet private var lastStepSubtitle: UILabel! {
        didSet {
            lastStepSubtitle.font = R.font.interRegular(size: 15.0)
        }
    }
    @IBOutlet private var okButton: UIButton! {
        didSet {
            okButton.titleLabel?.font = R.font.interMedium(size: 18.0)
            okButton.clipsToBounds = true
            okButton.layer.cornerRadius = 16.0
            okButton.setTitleColor(.white, for: .normal)
            okButton.backgroundColor = R.color.accentColor()
        }
    }
    @IBOutlet private var lastStepContainer: UIView!
    @IBOutlet private var lastStepImageContainer: UIView!
    @IBOutlet private var howToContainerView: UIView!
    @IBOutlet private var howToConnectFirstView: UIView!
    @IBOutlet private var howToConnectSecondView: UIView!
    @IBOutlet private var howToDisconnectView: UIView!
    private let disposeBag = DisposeBag()
    
    var tips: TipsType?
    
    // public
    public var tipsType: TipsType = .disconnect
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips = tipsType
        
        if let tips {
            switch tips {
            case .lastStep:
                lastStepContainer.isHidden = false
                lastStepImageContainer.isHidden = false
                howToContainerView.isHidden = true
            case .connect:
                lastStepContainer.isHidden = true
                lastStepImageContainer.isHidden = true
                howToDisconnectView.isHidden = true
                howToContainerView.isHidden = false
                howToLabel.text = R.string.localizable.how_To_Connect()
            case .disconnect:
                lastStepContainer.isHidden = true
                lastStepImageContainer.isHidden = true
                howToConnectFirstView.isHidden = true
                howToConnectSecondView.isHidden = true
                howToDisconnectView.isHidden = false
                howToContainerView.isHidden = false
                howToLabel.text = R.string.localizable.how_To_Disconnect()
            }
        }
    }
    
    static func showActionSheet(
        tipsType: TipsType,
        onViewController: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController) {
            
            guard let dialog = R.storyboard.tips.tipsVC() else { return }
            
            dialog.modalPresentationStyle = .overFullScreen
            dialog.tipsType = tipsType
            
            if let delegate = UIApplication.shared.delegate as? AppDelegate,
               let _ = delegate.window?.topViewController() as? TipsSheetController { } else {
                   onViewController?.topViewController().present(dialog, animated: true)
               }
        }
    
    
    @IBAction func okButtonAction(_ sender: Any) {
        hide(action: nil)
    }
    
    private func hide(_ success: Bool = false, action: (() -> Void)?) {
        modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true, completion: {
            guard let action = action else { return }
            action()
        })
    }
}
