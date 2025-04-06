//
//  BuySubscriptionViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import RxSwift
import RxCocoa

class BuySubscriptionViewController: UIViewController {
    
    @IBOutlet weak var dismissControllerButton: UIButton!
    
    @IBOutlet weak var couponImageView: UIImageView!
    @IBOutlet weak var couponSubtitleTextLabel: UILabel!
    @IBOutlet weak var couponReviewSubView: UIView!
    @IBOutlet weak var couponReviewPriceLabel: UILabel!
    @IBOutlet weak var couponReviewPriceTextLabel: UILabel!
    
    @IBOutlet weak var couponContinueButton: UIButton!
    
    @IBAction func termsOfUseAction(_ sender: Any) {
        EfficinacyCaller.shared.callHaptic()
        webUrlProvider("https://docs.google.com/document/d/1HohSixa6BjdF1Yhn7JJCXIJXWXRE-EfyGtCYaMYCJ0M/edit?tab=t.0")
    }
    @IBAction func restoreAction(_ sender: Any) {
        EfficinacyCaller.shared.callHaptic()
        Task {
            await DomesticPurchasesService.shared.restorePurchases()
        }
    }
    @IBAction func privacyPolicyAction(_ sender: Any) {
        EfficinacyCaller.shared.callHaptic()
        webUrlProvider("https://docs.google.com/document/d/1r2N_EZTQDYqP5y-xGUJwT_UTSFEQbFtcrz604U3mjFw/edit?tab=t.0")
    }
    
    let disposeBag = DisposeBag()
    let couponReviewData = DomesticPurchasesService.shared.review
    
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isBuySubsPresented = true
        
        setupButtons()
        setiingInterfaceContentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scaleButtonAnimation()
    }
    
    func scaleButtonAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 1.05
        pulseAnimation.duration = 1
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        couponContinueButton.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    func setiingInterfaceContentData() {
        guard let paywall = DomesticPurchasesService.shared.inAppPaywall else { return }
        
        couponSubtitleTextLabel.text = "Unlimited TV remote and screen mirroring with a 3-day free trial, then \(paywall.products.first?.localizedPrice ?? "$6.99/week") per week."
        couponReviewPriceTextLabel.text = "then \(paywall.products.first?.localizedPrice ?? "$6.99")/week"
        
        if couponReviewData {
            dismissControllerButton.setImage(UIImage(named: "beriobidsfjsda"), for: .normal)
            
            couponSubtitleTextLabel.isHidden = true
            couponReviewSubView.isHidden = false
            
            var configuration = couponContinueButton.configuration
            guard let paywall = DomesticPurchasesService.shared.inAppPaywall else { return }
            configuration?.title = "Start 3-Day Trial, then \(paywall.products.first?.localizedPrice ?? "$6.99/week")"
            configuration?.subtitle = "Auto renewable. Cancel anytime"
            configuration?.titleAlignment = .center
            configuration?.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ container in
                var container = container
                container.font = UIFont(name: "Inter-Regular", size: 14)
                container.foregroundColor = UIColor.white.withAlphaComponent(0.4)
                return container
            })
            configuration?.titleTextAttributesTransformer = .init({ container in
                var container = container
                container.font = UIFont(name: "Inter-SemiBold", size: 16)
                return container
            })
            couponContinueButton.configuration = configuration
            couponContinueButton.updateConfiguration()
            self.dismissControllerButton.isHidden = false
        } else {
            couponImageView.image = UIImage(named: "ehfwehfasdfas")
            dismissControllerButton.setImage(UIImage(named: "qwrwqofjas"), for: .normal)
            dismissControllerButton.isHidden = true
            
            couponSubtitleTextLabel.isHidden = false
            couponSubtitleTextLabel.textColor = UIColor(named: "с8E8E93")
            couponReviewSubView.isHidden = true
            
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Continue"
            configuration.titleTextAttributesTransformer = .init({ container in
                var container = container
                container.font = UIFont(name: "Inter-SemiBold", size: 16)
                return container
            })
            couponContinueButton.configuration = configuration
            couponContinueButton.updateConfiguration()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                self.dismissControllerButton.isHidden = false
            }
        }
    }
    
    func setupButtons() {
        dismissControllerButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let this = self else { return }
                EfficinacyCaller.shared.callHaptic()
                this.completion?()
                this.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        couponContinueButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let this = self else { return }
                EfficinacyCaller.shared.callHaptic()
                if let product = DomesticPurchasesService.shared.inAppPaywall?.products.first {
                    Task {
                        await DomesticPurchasesService.shared.makePurchase(product: product)
                        DispatchQueue.main.async {
                            this.completion?()
                            this.dismiss(animated: true)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        isBuySubsPresented = false
    }
}
