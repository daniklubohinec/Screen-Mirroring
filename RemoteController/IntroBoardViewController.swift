//
//  IntroBoardViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import RxSwift
import RxCocoa

var isBuySubsPresented = false

class IntroBoardViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    @IBOutlet weak var contentCollectionViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pageController: UIPageControl!
    @IBAction func pageControllerAction(_ sender: Any) {
        let pc = sender as! UIPageControl
        contentCollectionView.scrollToItem(at: IndexPath(item: pc.currentPage, section: 0),
                                           at: .centeredHorizontally, animated: true)
        changeConfiguration()
    }
    
    @IBOutlet weak var politicsButtonStackView: UIStackView!
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    @IBOutlet weak var reviewSubscriptionView: UIView!
    @IBOutlet weak var reviewPriceTextLabel: UILabel!
    @IBOutlet weak var reviewTrialTextLabel: UILabel!
    
    private let configReviewData = DomesticPurchasesService.shared.review
    
    let disposeBag = DisposeBag()
    var completion: (() -> Void)?
    
    var pages: [IntroBoardStructure] = [
        IntroBoardStructure(imageView: "bvwdsevwnds", titleLabel: "Universal TV Remote", subtitleLabel: "Control your smart TV effortlessly from your phone for easy navigation."),
        
        IntroBoardStructure(imageView: "bvwbvnweiojf", titleLabel: "Easily access and enjoy TV content", subtitleLabel: "Seamless touchpad navigation and fast, responsive keyboard input."),
        
        IntroBoardStructure(imageView: "erihgericdsas", titleLabel: "Cast Any Content from Your iPhone", subtitleLabel: "Effortlessly stream photos, videos, music, web content, and more with a single click."),
        
        IntroBoardStructure(imageView: "erbnigjiwefqw", titleLabel: "Get Full Access to All Features", subtitleLabel: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let paywall = DomesticPurchasesService.shared.inAppPaywall else { return }
        
        pages[3].subtitleLabel = "Unlimited TV remote and screen mirroring with a 3-day free trial, then \(paywall.products.first?.localizedPrice ?? "$6.99/week") per week."
        pages[3].imageView = DomesticPurchasesService.shared.review ? "erbnigjiwefqw" : "ehfwehfasdfas"
        reviewTrialTextLabel.text = "3-Day Trial"
        reviewPriceTextLabel.text = "then \(paywall.products.first?.localizedPrice ?? "$6.99")/week"
        
        isBuySubsPresented = true
        
        buttonConfiguration()
        
        contentCollectionViewBottomConstraint.constant = DomesticPurchasesService.shared.review ? -12 : 0
        pageController.isHidden = DomesticPurchasesService.shared.review ? true : false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bounceAnimation()
        
        pageController.numberOfPages = DomesticPurchasesService.shared.review ? self.pages.count : self.pages.count + 1
    }
    
    func buttonConfiguration() {
        nextButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let this = self else { return }
                EfficinacyCaller.shared.callHaptic()
                let visibleItems: NSArray = this.contentCollectionView.indexPathsForVisibleItems as NSArray
                let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
                let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
                if this.pageController.currentPage == 1 && this.configReviewData == false {
                    ApplicationRaitingCaller().requestImmediately()
                }
                
                if this.pageController.currentPage == 3 {
                    if let product = DomesticPurchasesService.shared.inAppPaywall?.products.first {
                        Task { [weak self] in
                            await DomesticPurchasesService.shared.makePurchase(product: product)
                            DispatchQueue.main.async { [weak self] in
                                self?.completion?()
                                self?.dismiss(animated: true)
                            }
                        }
                    }
                } else {
                    if nextItem.row < this.pages.count {
                        this.contentCollectionView.scrollToItem(at: nextItem, at: .left, animated: true)
                        this.pageController.currentPage = nextItem.row
                    }
                }
                this.changeConfiguration()
            })
            .disposed(by: disposeBag)
        
        termsOfUseButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let this = self else { return }
                EfficinacyCaller.shared.callHaptic()
                this.webUrlProvider("https://docs.google.com/document/d/1HohSixa6BjdF1Yhn7JJCXIJXWXRE-EfyGtCYaMYCJ0M/edit?tab=t.0")
            })
            .disposed(by: disposeBag)
        
        restoreButton.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                EfficinacyCaller.shared.callHaptic()
                Task {
                    await DomesticPurchasesService.shared.restorePurchases()
                }
            })
            .disposed(by: disposeBag)
        
        privacyPolicyButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let this = self else { return }
                EfficinacyCaller.shared.callHaptic()
                this.webUrlProvider("https://docs.google.com/document/d/1r2N_EZTQDYqP5y-xGUJwT_UTSFEQbFtcrz604U3mjFw/edit?tab=t.0")
            })
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let this = self else { return }
                EfficinacyCaller.shared.callHaptic()
                this.completion?()
                DataCollector.shared.onboardingShown = true
                this.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func changeConfiguration() {
        if pageController.currentPage == pageController.numberOfPages - 1 && configReviewData == true {
            dismissButton.setImage(UIImage(named: "beriobidsfjsda"), for: .normal)
            pageController.isHidden = true
            dismissButton.isHidden = false
            politicsButtonStackView.isHidden = false
            
            var configuration = nextButton.configuration
            guard let paywall = DomesticPurchasesService.shared.inAppPaywall else { return }
            configuration?.title = "Start 3-Day Trial, then \(paywall.products.first?.localizedPrice ?? "$6.99/week")"
            configuration?.subtitle = "Auto renewable. Cancel anytime"
            configuration?.titleAlignment = .center
            configuration?.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ container in
                var container = container
                container.font = UIFont(name: "Inter-Regular", size: 14)
                container.foregroundColor = UIColor.white.withAlphaComponent(0.5)
                return container
            })
            configuration?.titleTextAttributesTransformer = .init({ container in
                var container = container
                container.font = UIFont(name: "Inter-SemiBold", size: 16)
                return container
            })
            nextButton.configuration = configuration
            nextButton.updateConfiguration()
        } else if pageController.currentPage == pageController.numberOfPages - 2 && configReviewData == false {
            politicsButtonStackView.isHidden = false
            dismissButton.setImage(UIImage(named: "qwrwqofjas"), for: .normal)
            politicsButtonStackView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                self.dismissButton.isHidden = false
            }
        } else {
            if DomesticPurchasesService.shared.review {
                pageController.isHidden = true
            } else {
                pageController.isHidden = false
            }
            dismissButton.isHidden = true
            politicsButtonStackView.isHidden = true
            politicsButtonStackView.isHidden = true
        }
    }
    
    func bounceAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 1.05
        pulseAnimation.duration = 1
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        nextButton.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: "introBoardCellID", for: indexPath) as! IntroBoardCollectionViewCell
        cell.configureCell(boardScreen: pages[indexPath.item])
        cell.introBoardSubtitleText.textColor = configReviewData ? .white : UIColor(named: "с8E8E93")
        
        if pageController.currentPage == pageController.numberOfPages - 1 && configReviewData == true {
            reviewSubscriptionView.isHidden = false
            cell.introBoardSubtitleText.isHidden = true
        } else if pageController.currentPage == pageController.numberOfPages - 2 && configReviewData == false {
            reviewSubscriptionView.isHidden = true
            cell.introBoardSubtitleText.isHidden = false
        } else {
            reviewSubscriptionView.isHidden = true
            cell.introBoardSubtitleText.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.contentCollectionView.frame.height)
    }
    
    deinit {
        isBuySubsPresented = false
    }
}

extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}
