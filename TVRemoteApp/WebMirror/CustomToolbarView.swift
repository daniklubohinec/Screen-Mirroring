import UIKit

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
