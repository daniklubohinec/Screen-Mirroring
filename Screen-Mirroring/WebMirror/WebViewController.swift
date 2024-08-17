import Foundation
import WebKit
import SafariServices

final class WebViewController: BaseViewController, WKNavigationDelegate {
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()
    private lazy var toolbar: CustomToolbarView = {
        let view = CustomToolbarView()
        view.setBackButtonTarget(self, action: #selector(backButtonTapped))
        view.setForwardButtonTarget(self, action: #selector(forwardButtonTapped))
        view.setShareButtonTarget(self, action: #selector(shareButtonTapped))
        view.setTabsButtonTarget(self, action: #selector(tabsButtonTapped))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize and configure the WKWebView
        self.view.addSubview(webView)
        self.view.addSubview(toolbar)
        title = "Web Mirroring"
        navigationController?.setNavigationBarHidden(false, animated: true)

        // Load the desired URL
        if let url = URL(string: "https://www.google.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        webView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(toolbar.snp.top)
        }
        toolbar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(78)
            make.bottomMargin.equalToSuperview()
        }
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func backButtonTapped() {
        HapticGenerator.shared.generateImpact()
        webView.goBack()
    }
    
    @objc func forwardButtonTapped() {
        HapticGenerator.shared.generateImpact()
        webView.goForward()
    }
    
    @objc func shareButtonTapped() {
        guard let path = webView.url?.absoluteString else { return }
        HapticGenerator.shared.generateImpact()
        share(text: path)
    }
    
    @objc func tabsButtonTapped() {
        HapticGenerator.shared.generateImpact()
        UIPasteboard.general.string = webView.url?.absoluteString
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        toolbar.backButton.isEnabled = webView.canGoBack
        toolbar.forwardButton.isEnabled = webView.canGoForward
    }
}
final class CustomToolbarView: UIView {
    class BrowserButton: UIButton {
        override var isEnabled: Bool {
            didSet {
                tintColor = isEnabled ? .systemBlue : .gray
            }
        }
    }
    
    let backButton: BrowserButton = {
        let button = BrowserButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    let forwardButton: BrowserButton = {
        let button = BrowserButton()
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        let configuration = UIButton.Configuration.plain()
        button.tintColor = .gray  // Assuming the forward button is disabled
        return button
    }()
    
    private let shareButton: BrowserButton = {
        let button = BrowserButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let bookmarksButton: BrowserButton = {
        let button = BrowserButton()
        button.setImage(UIImage(systemName: "book"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let tabsButton: BrowserButton = {
        let button = BrowserButton()
        button.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let toolbarStackView: UIStackView

    override init(frame: CGRect) {
        toolbarStackView = UIStackView(arrangedSubviews: [backButton, forwardButton, shareButton, /*bookmarksButton, */tabsButton])
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        toolbarStackView = UIStackView(arrangedSubviews: [backButton, forwardButton, shareButton, /*bookmarksButton, */tabsButton])
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure the stack view
        toolbarStackView.axis = .horizontal
        toolbarStackView.distribution = .equalSpacing
        toolbarStackView.alignment = .center
        toolbarStackView.spacing = 20
        
        // Add the stack view to the view
        addSubview(toolbarStackView)
        
        // Set background color
        backgroundColor = .darkGray
        
        // Layout the stack view using SnapKit
        toolbarStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }
    }
    
    // MARK: - Public Methods to Access Buttons
    func setBackButtonTarget(_ target: Any?, action: Selector) {
        backButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setForwardButtonTarget(_ target: Any?, action: Selector) {
        forwardButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setShareButtonTarget(_ target: Any?, action: Selector) {
        shareButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setBookmarksButtonTarget(_ target: Any?, action: Selector) {
        bookmarksButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setTabsButtonTarget(_ target: Any?, action: Selector) {
        tabsButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
