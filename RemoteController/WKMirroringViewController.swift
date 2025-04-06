//
//  WKMirroringViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import WebKit
import SafariServices
import SnapKit

final class WKMirroringViewController: StandartTypeViewController, WKNavigationDelegate {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()
    
    private lazy var toolbar: FlowOwnToolbarView = {
        let toolbar = FlowOwnToolbarView()
        toolbar.setBackButtonTarget(self, action: #selector(backButtonTapped))
        toolbar.setForwardButtonTarget(self, action: #selector(forwardButtonTapped))
        toolbar.setShareButtonTarget(self, action: #selector(shareButtonTapped))
        toolbar.setTabsButtonTarget(self, action: #selector(tabsButtonTapped))
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialURL()
    }
    
    private func setupUI() {
        title = "Web Mirroring"
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(webView)
        view.addSubview(toolbar)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(toolbar.snp.top)
        }
        
        toolbar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(78)
            make.bottomMargin.equalToSuperview()
        }
    }
    
    private func loadInitialURL() {
        guard let url = URL(string: "https://www.google.com") else { return }
        webView.load(URLRequest(url: url))
    }
    
    @objc private func backButtonTapped() {
        EfficinacyCaller.shared.callHaptic()
        webView.goBack()
    }
    
    @objc private func forwardButtonTapped() {
        EfficinacyCaller.shared.callHaptic()
        webView.goForward()
    }
    
    @objc private func shareButtonTapped() {
        guard let url = webView.url?.absoluteString else { return }
        EfficinacyCaller.shared.callHaptic()
        shareApplicationURL(text: url)
    }
    
    @objc private func tabsButtonTapped() {
        EfficinacyCaller.shared.callHaptic()
        UIPasteboard.general.string = webView.url?.absoluteString
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        toolbar.backButton.isEnabled = webView.canGoBack
        toolbar.forwardButton.isEnabled = webView.canGoForward
    }
}

