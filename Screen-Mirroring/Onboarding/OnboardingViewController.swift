import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    private let review = PurchaseService.shared.review
    
    private let scrollView = UIScrollView()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = R.color.accentColor()!
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.2)
        return control
    }()
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = R.color.accentColor()
        configuration.baseForegroundColor = .white
        configuration.title = "Continue"
        configuration.titleTextAttributesTransformer = .init({ container in
            var container = container
            container.font = R.font.interSemiBold(size: 18)
            return container
        })
        configuration.subtitleTextAttributesTransformer = .init({ container in
            var container = container
            container.font = R.font.interMedium(size: 13)
            return container
        })
        button.configuration = configuration
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        
        return button
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = R.font.interSemiBold(size: 36)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = R.font.interRegular(size: 16)
        label.textColor = review ? UIColor.white : R.color.с8E8E93()
        label.textAlignment = .center
        return label
    }()
    private lazy var subView: SubscriptionOptionView = {
        let view = SubscriptionOptionView()
        view.isHidden = true
        return view
    }()
    private lazy var footer: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let termOfUse = UIButton()
        termOfUse.setAttributedTitle(NSAttributedString(string: "Terms Of use", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        termOfUse.setTitleColor(R.color.с8E8E93(), for: .normal)
        termOfUse.titleLabel?.font = R.font.interRegular(size: 13)
        termOfUse.addTarget(self, action: #selector(termsOfUseTapped), for: .touchUpInside)
        
        let restore = UIButton()
        restore.setAttributedTitle(NSAttributedString(string: "Restore", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        restore.setTitleColor(R.color.с8E8E93(), for: .normal)
        restore.titleLabel?.font = R.font.interRegular(size: 13)
        restore.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        
        let privacy = UIButton()
        privacy.setAttributedTitle(NSAttributedString(string: "Privacy policy", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue]), for: .normal)
        privacy.setTitleColor(R.color.с8E8E93(), for: .normal)
        privacy.titleLabel?.font = R.font.interRegular(size: 13)
        privacy.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [termOfUse, restore, privacy])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let image: UIImage? = {
            if !review {
                return UIImage(named: "ninjaCross")
            }
            return UIImage(named: "cross")
        }()
        button.isHidden = !review
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
        button.isHidden = true
        
        return button
    }()
    
    private var continueButtonTopLabelConstraint: Constraint?
    private var continueButtonTopViewConstraint: Constraint?
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.addSubview(pageControl)
        view.addSubview(titleLabel)
        view.addSubview(subView)
        view.addSubview(descriptionLabel)
        view.addSubview(continueButton)
        view.addSubview(footer)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.top).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-12)
            make.height.equalTo(88)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
            // make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.bottom.equalTo(pageControl.snp.top).offset(-12)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(review ? 0 : 44)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            make.bottom.equalTo(continueButton.snp.top).offset(-12)
        }
        
        subView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(64)
        }
        
        continueButton.snp.makeConstraints { make in
            continueButtonTopLabelConstraint = make.top.equalTo(pageControl.snp.bottom).offset(12).constraint
            continueButtonTopViewConstraint = make.top.equalTo(subView.snp.bottom).offset(24).constraint
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(64)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-32)
        }
        
        footer.snp.makeConstraints { make in
            make.top.equalTo(continueButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(48)
            make.trailing.equalToSuperview().offset(-48)
        }
        continueButtonTopViewConstraint?.isActive = true
        
        return view
    }()
    private let pages: [OnboardingPage]
    private lazy var pagesView: [UIView] = {
        return pages.compactMap { page in
            return OnboardingPageView(image: page.image, title: page.title, description: page.subtitle)
        }
    }()
    private let disposeBag = DisposeBag()
    var completion: (() -> Void)?
    
    init(pages: [OnboardingPage] = OnboardingPage.allCases) {
        self.pages = pages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupScrollView()
        setupPageControl()
        setupContinueButton()
        titleLabel.text = OnboardingPage.firstScreen.title
        descriptionLabel.text = OnboardingPage.firstScreen.subtitle
        
        pageControl.isHidden = review
        footer.isHidden = !(pages.count == 1)
        
        // Paywall setup
        if pages.count == 1 {
            pageControl.isHidden = true
            pageControl.snp.makeConstraints { make in
                make.height.equalTo(0)
            }
        }
        
        if review, pages.count == 1 {
            footer.isHidden = false
            subView.isHidden = false
            descriptionLabel.isHidden = true
            continueButtonTopLabelConstraint?.isActive = false
            closeButton.isHidden = false
            continueButtonTopViewConstraint?.isActive = true
            updateContinueButton(page: .fourthScreen)
            titleLabel.text = OnboardingPage.fourthScreen.title
        } else if !review, pages.count == 1 {
            titleLabel.text = OnboardingPage.fourthScreen.title
            descriptionLabel.text = OnboardingPage.fourthScreen.subtitle
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !review, pageControl.numberOfPages == 1  {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                self.closeButton.isHidden = false
            }
        }
        pulseAnimation()
    }
    
    func pulseAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 0.98
        pulseAnimation.toValue = 1.02
        pulseAnimation.duration = 1
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        continueButton.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        view.addSubview(bottomContainerView)
        view.addSubview(closeButton)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.snp.topMargin).offset(8)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            // make.height.equalTo(358)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainerView.snp.top).offset(-10)
        }
        
        var previousPage: UIView? = nil
        for page in pagesView {
            scrollView.addSubview(page)
            page.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.height.equalTo(scrollView.frameLayoutGuide)
                make.bottom.equalToSuperview()
                make.width.equalTo(view)
                if let previousPage = previousPage {
                    make.left.equalTo(previousPage.snp.right)
                } else {
                    make.left.equalToSuperview()
                }
            }
            previousPage = page
        }
        
        if let lastPage = pagesView.last {
            scrollView.snp.makeConstraints { make in
                make.right.equalTo(lastPage.snp.right)
            }
        }
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = PurchaseService.shared.review ? pages.count : pages.count + 1
        pageControl.currentPage = 0
    }
    
    private func setupContinueButton() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private var scrolledByButton = false
    @objc private func continueButtonTapped() {
        let currentPage = pageControl.currentPage
        HapticGenerator.shared.generateImpact()
        if currentPage < pages.count - 1 {
            scrolledByButton = true
            let nextPage = CGPoint(x: scrollView.bounds.width * CGFloat(currentPage + 1), y: 0)
            scrollView.setContentOffset(nextPage, animated: true)
            pageControl.currentPage = currentPage + 1
            updateLabels(page: currentPage + 1)
        } else {
            Storage.shared.onboardingShown = true
            if let product = PurchaseService.shared.inAppPaywall?.products.first {
                Task { [weak self] in
                    await PurchaseService.shared.makePurchase(product: product)
                    DispatchQueue.main.async { [weak self] in
                        self?.completion?()
                        self?.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrolledByButton else {
            return
        }
        let pageIndex = round(scrollView.contentOffset.x / view.bounds.width)
        if pageControl.currentPage != Int(pageIndex) {
            updateLabels(page: Int(pageIndex))
        }
        pageControl.currentPage = Int(pageIndex)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrolledByButton {
            scrolledByButton = false
        }
    }
    
    private func updateContinueButton(page: OnboardingPage) {
        if page == .fourthScreen, review {
            var configuration = continueButton.configuration
            guard let paywall = PurchaseService.shared.inAppPaywall else { return }
            configuration?.title = "\(paywall.config.purchaseTitle) \(paywall.config.priceDescription) \(paywall.products.first?.localizedPrice ?? "$6.99/week")"
            configuration?.subtitle =  paywall.config.priceSubtitle
            configuration?.titleAlignment = .center
            configuration?.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ container in
                var container = container
                container.font = R.font.interRegular(size: 14.0)
                container.foregroundColor = UIColor.white.withAlphaComponent(0.5)
                return container
            })
            configuration?.titleTextAttributesTransformer = .init({ container in
                var container = container
                container.font = R.font.interSemiBold(size: 16)
                return container
            })
            continueButton.configuration = configuration
            continueButton.updateConfiguration()
            
            remakeConstraint(page)
        } else {
            var configuration = UIButton.Configuration.filled()
            configuration.baseForegroundColor = .white
            configuration.title = "Continue"
            configuration.titleTextAttributesTransformer = .init({ container in
                var container = container
                container.font = R.font.interSemiBold(size: 18)
                return container
            })
            continueButton.configuration = configuration
            continueButton.updateConfiguration()
        }
    }
    
    private var requested = false
    private func updateLabels(page: Int) {
        guard let page = OnboardingPage(rawValue: page) else { return }
        animateTextChange(for: titleLabel, newText: page.title)
        animateTextChange(for: descriptionLabel, newText: page.subtitle)
        descriptionLabel.isHidden = page == .fourthScreen
        subView.isHidden = page != .fourthScreen
        
        remakeConstraint(page)
        
        footer.isHidden = page != .fourthScreen
        if !review, pageControl.numberOfPages == 1 || page == .fourthScreen {
            subView.isHidden = true
            descriptionLabel.isHidden = false
            updateContinueButton(page: page)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                self.closeButton.isHidden = false
            }
            guard let paywall = PurchaseService.shared.inAppPaywall else { return }
            descriptionLabel.text = "\(paywall.config.descriptionSubtitle) \(paywall.products.first?.localizedPrice ?? "$6.99/week") \(paywall.config.descriptionPerWeek)"
        } else {
            updateContinueButton(page: page)
            closeButton.isHidden = page != .fourthScreen
        }
        if page == .secondScreen, !requested, !review {
            requested = true
            AppReview().requestImmediately()
        }
    }
    
    func remakeConstraint(_ page: OnboardingPage) {
        if review {
            pageControl.snp.remakeConstraints { make in
                make.height.equalTo(page == .fourthScreen ? 44 : 0)
            }
            continueButtonTopLabelConstraint?.isActive = page != .fourthScreen
            continueButtonTopViewConstraint?.isActive = page == .fourthScreen
        }
    }
    
    private func animateTextChange(for label: UILabel, newText: String) {
        UIView.animate(withDuration: 0.35, animations: {
            label.alpha = 0
        }) { (completed) in
            label.text = newText
            UIView.animate(withDuration: 0.35, animations: {
                label.alpha = 1
            })
        }
    }
    
    @objc
    private func closeScreen() {
        HapticGenerator.shared.generateImpact()
        Storage.shared.onboardingShown = true
        completion?()
        dismiss(animated: true)
    }
    
    @objc private func termsOfUseTapped() {
        loadURLString("https://docs.google.com/document/d/1PpzLeabieTxRZz6yfQ_8ijMKmOi2vmPFKwxr0ZQiOfA/edit")
    }
    
    @objc private func restoreTapped() {
        Task {
            await PurchaseService.shared.restorePurchases()
        }
    }
    
    @objc private func privacyTapped() {
        loadURLString("https://docs.google.com/document/d/1XWGMkuhwJndeEZbz1PzPgXvCBicTj9hMSVmQ6UmklOA/edit")
    }
    
}

final class OnboardingPageView: UIView {
    
    init(image: UIImage?, title: String, description: String) {
        super.init(frame: .zero)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class SubscriptionOptionView: UIView {
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let freeTrialLabel: UILabel = {
        let label = UILabel()
        if let paywall = PurchaseService.shared.inAppPaywall {
            label.text = paywall.config.trial
        }
        label.font = R.font.interSemiBold(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        if let paywall = PurchaseService.shared.inAppPaywall {
            label.text = "\(paywall.config.priceDescription) \(paywall.products.first?.localizedPrice ?? "$6.99/week")"
        }
        label.font = R.font.interRegular(size: 14)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = R.color.c1C1C1E()
        layer.cornerRadius = 16
        
        addSubview(checkmarkImageView)
        addSubview(freeTrialLabel)
        addSubview(priceLabel)
        
        checkmarkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(20)
        }
        
        freeTrialLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkmarkImageView.snp.trailing).offset(8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(freeTrialLabel.snp.trailing).offset(8)
        }
    }
    
    func configure(with price: String, duration: String) {
        priceLabel.text = price
        freeTrialLabel.text = duration
    }
}
