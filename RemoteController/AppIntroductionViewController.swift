//
//  AppIntroductionViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import Combine

final class AppIntroductionViewController: UIViewController {
    
    @IBOutlet private var indicator: UIActivityIndicatorView!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeInAppPaywall()
    }
    
    private func setupUI() {
        indicator.startAnimating()
    }
    
    private func observeInAppPaywall() {
        DomesticPurchasesService.shared.$inAppPaywall
            .receive(on: DispatchQueue.main)
            .sink { [weak self] paywall in
                guard paywall != nil else { return }
                self?.handlePaywallState()
            }
            .store(in: &cancellables)
    }
    
    private func handlePaywallState() {
        showMainViewController()
        if shouldShowOnboarding() {
            showOnboarding()
        } else {
            unhideMainView()
        }
    }
    
    private func shouldShowOnboarding() -> Bool {
        return !DataCollector.shared.onboardingShown && !DomesticPurchasesService.shared.hasPremium
    }
    
    private func showMainViewController() {
        guard let mainViewController = UIStoryboard(name: "OnFlowCasts", bundle: nil).instantiateInitialViewController() else {
            return
        }
        
        mainViewController.modalTransitionStyle = .crossDissolve
        mainViewController.modalPresentationStyle = .fullScreen
        addChild(mainViewController)
        view.addSubview(mainViewController.view)
        mainViewController.view.frame = view.bounds
        mainViewController.didMove(toParent: self)
        mainViewController.view.isHidden = true
    }
    
    private func unhideMainView() {
        children.first?.view.isHidden = false
    }
    
    private func showOnboarding() {
        let onboardingVC = UIStoryboard(name: "IntroBoard", bundle: .main).instantiateViewController(identifier: "IntroBoardViewController") as IntroBoardViewController
        onboardingVC.completion = { [weak self] in self?.unhideMainView() }
        onboardingVC.modalPresentationStyle = .fullScreen
        present(onboardingVC, animated: false)
    }
}

