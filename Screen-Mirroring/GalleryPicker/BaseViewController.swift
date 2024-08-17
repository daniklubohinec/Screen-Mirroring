import UIKit
import AVKit
import RxRelay

class BaseViewController: UIViewController, AVRoutePickerViewDelegate {
    static var routeDismissed: BehaviorRelay<Bool> = .init(value: false)
    
    private lazy var wrapper: CustomAirPlayWrapper = {
        let view = CustomAirPlayWrapper(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        view.routePickerView.delegate = self
        return view
    }()
    private lazy var airplayButton: UIBarButtonItem = {
        return UIBarButtonItem(customView: wrapper)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAirplayButton()
    }
    
    private func setupAirplayButton() {
        navigationItem.rightBarButtonItem = airplayButton
    }
    
    // MARK: - AVRoutePickerViewDelegate
    
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        BaseViewController.routeDismissed.accept(false)
    }
    
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        BaseViewController.routeDismissed.accept(true)
        if self is MediaViewController || self is WebViewController || self is DocumentViewController {
            AppReview().requestIfNeeded()
        }
    }
    
    func openAirplayMenu() {
        wrapper.routePickerView.showAirplayView()
    }
    
    
    static func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

final class CustomAirPlayWrapper: UIView {
    
    let routePickerView = AVRoutePickerView()
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(R.image.airplay(), for: .normal)
        button.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        routePickerView.frame = bounds
        routePickerView.isHidden = true
        addSubview(routePickerView)
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func viewTapped() {
        HapticGenerator.shared.generateImpact()
        
        // Simulate a tap on the AVRoutePickerView
        for view in routePickerView.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
    }
}
