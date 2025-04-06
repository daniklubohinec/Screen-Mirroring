//
//  AdaptationViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import RxSwift
import RxCocoa
import MessageUI

final class AdaptationViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var rateUsBackView: UIView!
    @IBOutlet private weak var rateUsButton: UIButton!
    
    @IBOutlet private weak var shareAppBackView: UIView!
    @IBOutlet private weak var shareAppButton: UIButton!
    
    @IBOutlet private weak var contactUsBackView: UIView!
    @IBOutlet private weak var contactUsButton: UIButton!
    
    @IBOutlet private weak var restoreBackView: UIView!
    @IBOutlet private weak var restoreButton: UIButton!
    
    @IBOutlet private weak var privacyBackView: UIView!
    @IBOutlet private weak var privacyButton: UIButton!
    
    @IBOutlet private weak var termsBackView: UIView!
    @IBOutlet private weak var termsButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Settings"
        animateButtonViews()
    }
    
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
    }
    
    private func animateButtonViews() {
        let buttons: [(UIButton, UIView)] = [
            (rateUsButton, rateUsBackView),
            (shareAppButton, shareAppBackView),
            (contactUsButton, contactUsBackView),
            (restoreButton, restoreBackView),
            (privacyButton, privacyBackView),
            (termsButton, termsBackView)
        ]
        
        buttons.forEach { animateButtonView($0.0, $0.1, disposeBag) }
    }
    
    // MARK: - Action Methods
    @IBAction private func rateUsTapped() {
        triggerHapticFeedback()
        ApplicationRaitingCaller().requestImmediately()
    }
    
    @IBAction private func shareAppTapped() {
        triggerHapticFeedback()
        let activityController = UIActivityViewController(activityItems: ["https://itunes.apple.com/app/id"], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    @IBAction private func contactUsTapped() {
        triggerHapticFeedback()
        
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Error", message: "Device is not able to send an email")
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["gomkplaz@hotmail.com"])
        present(mail, animated: true)
    }
    
    @IBAction private func restoreTapped() {
        triggerHapticFeedback()
        // Restore purchases logic if applicable
    }
    
    @IBAction private func privacyTapped() {
        triggerHapticFeedback()
        loadURL("https://docs.google.com/document/d/1r2N_EZTQDYqP5y-xGUJwT_UTSFEQbFtcrz604U3mjFw/edit?tab=t.0")
    }
    
    @IBAction private func termsOfUseTapped() {
        triggerHapticFeedback()
        loadURL("https://docs.google.com/document/d/1HohSixa6BjdF1Yhn7JJCXIJXWXRE-EfyGtCYaMYCJ0M/edit?tab=t.0")
    }
    
    // MARK: - Helper Methods
    private func triggerHapticFeedback() {
        EfficinacyCaller.shared.callHaptic()
    }
    
    private func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - MFMailComposeViewController Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
