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
        title = R.string.localizable.web_Mirroring()
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
