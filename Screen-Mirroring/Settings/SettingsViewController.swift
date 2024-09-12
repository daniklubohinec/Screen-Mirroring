//
//  SettingsViewController.swift
//  QR-Reader
//
//  Created by Liver Pauler on 08.01.24.
//

import UIKit
import RxSwift
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var rateUsBackView: UIView!
    @IBOutlet weak var rateUsButton: UIButton!
    
    @IBOutlet weak var shareAppBackView: UIView!
    @IBOutlet weak var shareAppButton: UIButton!
    
    @IBOutlet weak var contactUsBackView: UIView!
    @IBOutlet weak var contactUsButton: UIButton!
    
    @IBOutlet weak var restoreBackView: UIView!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet weak var privacyBackView: UIView!
    @IBOutlet weak var privacyButton: UIButton!
    
    @IBOutlet weak var termsBackView: UIView!
    @IBOutlet weak var termsButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        animateButtonViews()
    }
    
    //MARK: MFMail Compose ViewController Delegate method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func animateButtonViews() {
        animateButtonView(rateUsButton, rateUsBackView, disposeBag)
        animateButtonView(shareAppButton, shareAppBackView, disposeBag)
        animateButtonView(contactUsButton, contactUsBackView, disposeBag)
        
        animateButtonView(restoreButton, restoreBackView, disposeBag)
        animateButtonView(privacyButton, privacyBackView, disposeBag)
        animateButtonView(termsButton, termsBackView, disposeBag)
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
            let alert = UIAlertController(title: "Error", message: "Device is not able to send an email", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Close", style: .cancel)
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
}
