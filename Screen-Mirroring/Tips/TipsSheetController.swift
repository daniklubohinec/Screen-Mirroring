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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                howToLabel.text = "How to Connect"
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
        
        okButton.rx.tap
            .subscribe(onNext: { [weak self] in
                HapticGenerator.shared.generateImpact()
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
