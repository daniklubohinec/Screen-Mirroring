import UIKit
import RxSwift
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var rateUsBackView: UIView!
    @IBOutlet weak var rateUsButton: UIButton!
    @IBOutlet weak var rateTitle: UILabel! {
        didSet {
            rateTitle.text = R.string.localizable.rate_Us()
        }
    }
    
    @IBOutlet weak var shareAppBackView: UIView!
    @IBOutlet weak var shareAppButton: UIButton!
    @IBOutlet weak var shareTitle: UILabel! {
        didSet {
            shareTitle.text = R.string.localizable.share_App()
        }
    }

    @IBOutlet weak var contactUsBackView: UIView!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var contactsTitle: UILabel! {
        didSet {
            contactsTitle.text = R.string.localizable.contact_Us()
        }
    }

    @IBOutlet weak var restoreBackView: UIView!
    @IBOutlet weak var restoreButton: UIButton!

    @IBOutlet weak var privacyBackView: UIView!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var privacyTitle: UILabel! {
        didSet {
            privacyTitle.text = R.string.localizable.privacy_Policy()
        }
    }

    @IBOutlet weak var termsBackView: UIView!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsTitle: UILabel! {
        didSet {
            termsTitle.text = R.string.localizable.terms_Of_Use()
        }
    }

    @IBOutlet weak var miniGameBackView: UIView!
    @IBOutlet weak var miniGameButton: UIButton!
    @IBOutlet weak var miniGameTitle: UILabel! {
        didSet {
            miniGameTitle.text = R.string.localizable.mini_Game()
        }
    }
    @IBOutlet weak var socialTitle: UILabel! {
        didSet {
            socialTitle.text = R.string.localizable.social()
        }
    }
    @IBOutlet weak var feedbackTitle: UILabel! {
        didSet {
            feedbackTitle.text = R.string.localizable.feedback()
        }
    }

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = R.string.localizable.settings_Title()
        animateButtonViews()
    }
    
    //MARK: MFMail Compose ViewController Delegate method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func animateButtonViews() {
        let buttons: [(UIButton, UIView)] = [
            (rateUsButton, rateUsBackView),
            (shareAppButton, shareAppBackView),
            (contactUsButton, contactUsBackView),
            (restoreButton, restoreBackView),
            (privacyButton, privacyBackView),
            (termsButton, termsBackView)
        ]
        
        buttons.forEach { button, backView in
            animateButtonView(button, backView, disposeBag)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    @IBAction
    func rateUs() {
        HapticGenerator.shared.generateImpact()
        AppReview().requestImmediately()
    }
    
    @IBAction
    func shareApp() {
        HapticGenerator.shared.generateImpact()
        let linkToShare = ["https://itunes.apple.com/app/id"]
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction
    func contactUs() {
        HapticGenerator.shared.generateImpact()
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["biaginiuberto@gmail.com"])
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: R.string.localizable.error(), message: R.string.localizable.email_Invalid(), preferredStyle: .alert)
            let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
    }
    
    
    /// On Onboarding same things
    @IBAction
    private func restoreTapped() {
        HapticGenerator.shared.generateImpact()
    }
    
    @IBAction
    private func privacyTapped() {
        HapticGenerator.shared.generateImpact()
        loadURLString("https://docs.google.com/document/d/1XWGMkuhwJndeEZbz1PzPgXvCBicTj9hMSVmQ6UmklOA/edit")
    }
    
    @IBAction
    private func termsOfUseTapped() {
        HapticGenerator.shared.generateImpact()
        loadURLString("https://docs.google.com/document/d/1PpzLeabieTxRZz6yfQ_8ijMKmOi2vmPFKwxr0ZQiOfA/edit")
    }
    
    @IBAction
    private func miniGameTapped() {
        HapticGenerator.shared.generateImpact()
        let ticTacToeVC = TicTacToeViewController()
        present(ticTacToeVC, animated: true, completion: nil)
    }
}
