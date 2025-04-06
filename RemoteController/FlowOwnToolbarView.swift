//
//  FlowOwnToolbarView.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import SnapKit

final class FlowOwnToolbarView: UIView {
    class BrowserButton: UIButton {
        override var isEnabled: Bool {
            didSet {
                tintColor = isEnabled ? .systemBlue : .gray
            }
        }
    }
    
    // MARK: - Buttons
    let backButton = BrowserButton()
    let forwardButton = BrowserButton()
    private let shareButton = BrowserButton()
    private let tabsButton = BrowserButton()
    
    private lazy var toolbarStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, forwardButton, shareButton, tabsButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        backgroundColor = .darkGray
        setupButtons()
        setupLayout()
    }
    
    private func setupButtons() {
        configureButton(backButton, imageName: "chevron.backward", tintColor: .systemBlue)
        configureButton(forwardButton, imageName: "chevron.forward", tintColor: .gray) // Disabled initially
        configureButton(shareButton, imageName: "square.and.arrow.up", tintColor: .systemBlue)
        configureButton(tabsButton, imageName: "square.on.square", tintColor: .systemBlue)
    }
    
    private func configureButton(_ button: BrowserButton, imageName: String, tintColor: UIColor) {
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = tintColor
    }
    
    private func setupLayout() {
        addSubview(toolbarStackView)
        
        toolbarStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }
    }
    
    // MARK: - Public Methods to Assign Targets
    func setBackButtonTarget(_ target: Any?, action: Selector) {
        backButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setForwardButtonTarget(_ target: Any?, action: Selector) {
        forwardButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setShareButtonTarget(_ target: Any?, action: Selector) {
        shareButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setTabsButtonTarget(_ target: Any?, action: Selector) {
        tabsButton.addTarget(target, action: action, for: .touchUpInside)
    }
}

final class TabBarViewController: UITabBarController {
    
    // MARK: - Constants
    private enum TabBarConfig {
        static let tvRemoteTitle = "TV Remote"
        static let tvRemoteImageName = "weigfwefdfasdasdas"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTVRemoteTab()
    }
    
    // MARK: - Setup Methods
    private func setupTVRemoteTab() {
        let RemoteViewController = RemoteControllerCovering.createTVRemoteView()
        RemoteViewController.tabBarItem = UITabBarItem(
            title: TabBarConfig.tvRemoteTitle,
            image: UIImage(named: TabBarConfig.tvRemoteImageName),
            tag: 0
        )
        
        let navigationController = UINavigationController(rootViewController: RemoteViewController)
        viewControllers = ([navigationController] + (viewControllers ?? []))
    }
}
