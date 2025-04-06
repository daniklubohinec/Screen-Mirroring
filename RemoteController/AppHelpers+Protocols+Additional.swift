//
//  AppHelpers+Protocols+Additional.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import Photos
import Network
import RxSwift
import RxCocoa
import RxRelay
import StoreKit
import QuartzCore
import AVFoundation
import SwiftUI

func onMainFlow(f: @escaping (() -> Void)) {
    DispatchQueue.main.async {
        f()
    }
}

func openApplicationConfiguration() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

func shareApplicationURL(
    text: String,
    onViewController: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
) {
    let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    activityViewController.excludedActivityTypes = [
        .assignToContact,
        .addToReadingList
    ]
    
    onViewController?.present(activityViewController, animated: true, completion: nil)
}

final class ScrennCastingDevices {
    private init() { }
    static var connected = false
    
    static func getCurrentScreenCastingDevice() -> String? {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        for output in currentRoute.outputs {
            if output.portType == AVAudioSession.Port.airPlay {
                return output.portName
            }
        }
        
        return nil
    }
    
    static func startWatchingScreenCastingChanges(callback: @escaping (String?) -> Void) {
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
            }
            
            switch reason {
            case .newDeviceAvailable, .oldDeviceUnavailable, .override:
                // The route has changed, so check for the current AirPlay device
                let currentDevice = getCurrentScreenCastingDevice()
                connected = currentDevice != nil
                callback(currentDevice)
                if !isScreenCastingActive() {
                    
                }
            default:
                break
            }
        }
    }
    
    static func stopWatchingScreenCastingChanges() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
}

func isScreenCastingActive() -> Bool {
    let sessions = UIApplication.shared.openSessions
    for session in sessions {
        if let screen = (session.scene as? UIWindowScene)?.screen, screen.mirrored != nil {
            return true
        }
    }
    return false
}

public class NetworkUsagePermissionHelper {
    
    public static let shared = NetworkUsagePermissionHelper()
    
    private init() {}
    
    public func isUserConnectToWiFi() -> Bool {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        let semaphore = DispatchSemaphore(value: 0)
        var isConnected = false
        
        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
        }
        monitor.start(queue: .global())
        semaphore.wait()
        monitor.cancel()
        
        return isConnected
    }
    
    public func toDeviceWiFiSettings() {
        if let url = URL(string: "App-Prefs:root=WIFI") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func requestUserLocalNetworkPermission(completion: @escaping ((Bool) -> Void)) {
        let parameters = NWParameters.tcp
        let browser = NWBrowser(for: .bonjour(type: "_http._tcp", domain: nil), using: parameters)
        
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .failed(let error):
                print("Browser failed with error: \(error)")
                completion(false)
            default:
                completion(true)
                break
            }
        }
        
        browser.browseResultsChangedHandler = { results, changes in
            for result in results {
                print("Found service: \(result)")
            }
        }
        
        browser.start(queue: .main)
    }
}

protocol ImpactCaller {
    func callHaptic()
}

final class EfficinacyCaller: ImpactCaller {
    static let shared = EfficinacyCaller()
    
    // MARK: Internal
    private init() { }
    
    func callHaptic() {
        impact.impactOccurred()
    }
    
    // MARK: Fileprivate
    fileprivate let impact = UIImpactFeedbackGenerator(style: .light)
}

final public class DataCollector {
    static let shared = DataCollector(userDefaults: .standard, encoder: JSONEncoder(), decoder: JSONDecoder())
    
    // MARK: - Private properties
    private let queue = DispatchQueue(label: String(describing: DataCollector.self), qos: .utility)
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var subjects: [String: Any] = [:]
    
    private init(userDefaults: UserDefaults, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - Public methods
    
    /// Returns value in user defaults in case if there is one for current user. Returns nil if not.
    public func stored<T: Codable>(at key: String) -> T? {
        let item: T? = userDefaults.data(forKey: key)
            .flatMap { try? decoder.decode(T.self, from: $0) }
        getSubject(for: key).accept(item)
        return item
    }
    
    /// Store value in user defaults for specific user. Returns the same value (convenience for Signal)
    public func store<T: Codable>(value: T, at key: String) {
        queue.async { [weak self] in
            guard let self else { return }
            if let encoded = try? self.encoder.encode(value) {
                self.userDefaults.set(encoded, forKey: key)
            }
            self.getSubject(for: key).accept(value)
        }
    }
    
    /// Removes any value for specified key at specified scope
    public func remove(at key: String) {
        queue.async { [weak self] in
            self?.userDefaults.set(nil, forKey: key)
        }
    }
    
    /// We need this to ensure the data is written
    public func synchronize() {
        userDefaults.synchronize()
    }
    
    /// Returns an Observable for the specified key
    public func observable<T: Codable>(for key: String) -> Observable<T?> {
        defer { let _: T? = stored(at: key) }
        return getSubject(for: key).asObservable()
    }
    
    // MARK: - Private methods
    
    private func getSubject<T: Codable>(for key: String) -> BehaviorRelay<T?> {
        if let subject = subjects[key] as? BehaviorRelay<T?> {
            return subject
        }
        let subject = BehaviorRelay<T?>(value: nil)
        subjects[key] = subject
        return subject
    }
}

extension DataCollector {
    var onboardingShown: Bool {
        get {
            let shown: Bool = DataCollector.shared.stored(at: "onboardingShown") ?? false
            return shown
        }
        set {
            DataCollector.shared.store(value: newValue, at: "onboardingShown")
        }
    }
}

class RoundProgressBar: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var tracklayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureProgressViewToBeCircular()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureProgressViewToBeCircular()
    }
    
    var setProgressColor: UIColor = UIColor.red {
        didSet {
            progressLayer.strokeColor = setProgressColor.cgColor
        }
    }
    
    var setTrackColor: UIColor = UIColor.white {
        didSet {
            tracklayer.strokeColor = setTrackColor.cgColor
        }
    }
    /**
     A path that consists of straight and curved line segments that you can render in your custom views.
     Meaning our CAShapeLayer will now be drawn on the screen with the path we have specified here
     */
    private var viewCGPath: CGPath? {
        return UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                            radius: (frame.size.width - 1.5) / 2,
                            startAngle: CGFloat(-0.5 * Double.pi),
                            endAngle: CGFloat(1.5 * Double.pi), clockwise: true).cgPath
    }
    
    private func configureProgressViewToBeCircular() {
        self.drawsView(using: tracklayer, startingPoint: 20.0, ending: 1.0)
        self.drawsView(using: progressLayer, startingPoint: 20.0, ending: 0.0)
    }
    
    private func drawsView(using shape: CAShapeLayer, startingPoint: CGFloat, ending: CGFloat) {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width / 2.0
        
        shape.path = self.viewCGPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = setProgressColor.cgColor
        shape.lineWidth = startingPoint
        shape.strokeEnd = ending
        
        self.layer.addSublayer(shape)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        
        animation.fromValue = 0 //start animation at point 0
        animation.toValue = value //end animation at point specified
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateCircle")
    }
}

public class ApplicationRaitingCaller {
    
    public let minLaunches: Int
    public let minDays: Int
    
    public init(minLaunches: Int = 0, minDays: Int = 0) {
        self.minLaunches = minLaunches
        self.minDays = minDays
    }
    
    @discardableResult
    public static func requestIf(launches: Int = 0, days: Int = 0) -> Bool {
        ApplicationRaitingCaller(minLaunches: launches, minDays: days).requestIfNeeded()
    }
    
    private let ud = UserDefaults.standard
    
    public var launches: Int {
        get { ud.integer(forKey: "AppReviewLaunches") }
        set(value) { ud.set(value, forKey: "AppReviewLaunches") }
    }
    
    public var firstLaunchDate: Date? {
        get { ud.object(forKey: "AppReviewFirstLaunchDate") as? Date }
        set(value) { ud.set(value, forKey: "AppReviewFirstLaunchDate") }
    }
    
    public var lastReviewDate: Date? {
        get { ud.object(forKey: "AppReviewLastReviewDate") as? Date }
        set(value) { ud.set(value, forKey: "AppReviewLastReviewDate") }
    }
    
    public var lastReviewVersion: String? {
        get { ud.string(forKey: "AppReviewLastReviewVersion") }
        set(value) { ud.set(value, forKey: "AppReviewLastReviewVersion") }
    }
    
    public var daysAfterFirstLaunch: Int {
        if let date = firstLaunchDate {
            return daysBetween(date, Date())
        }
        return 0
    }
    
    public var daysAfterLastReview: Int {
        if let date = lastReviewDate {
            return daysBetween(date, Date())
        }
        return 0
    }
    
    public var isNeeded: Bool {
        launches >= minLaunches &&
        daysAfterFirstLaunch >= minDays &&
        (lastReviewDate == nil || daysAfterLastReview >= 125) &&
        lastReviewVersion != version
    }
    
    @discardableResult
    public func requestIfNeeded() -> Bool {
        if firstLaunchDate == nil { firstLaunchDate = Date() }
        launches += 1
        guard isNeeded else { return false }
        lastReviewDate = Date()
        lastReviewVersion = version
        request()
        return true
    }
    
    public func requestImmediately() {
        request()
    }
    
    private func request() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
#if os(iOS)
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } else {
                SKStoreReviewController.requestReview()
            }
#else
            SKStoreReviewController.requestReview()
#endif
        }
    }
    
    internal var version = Bundle.main.object(
        forInfoDictionaryKey: "CFBundleShortVersionString"
    ) as! String
    
    internal func daysBetween(_ start: Date, _ end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
}

extension UIViewController {
    func firstInFlowViewController() -> UIViewController {
        var topController = self
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    func present(_ viewControllerToPresent: UIViewController?, animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let viewController = viewControllerToPresent else {
            return
        }
        self.present(viewController, animated: flag, completion: completion)
    }
    
    func animateButtonView(_ button: UIButton, _ backView: UIView, _ disposeBag: DisposeBag) {
        button.rx.controlEvent(.touchDown)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { _ in
                backView.alpha = 0.75
            })
            .disposed(by: disposeBag)
        
        button.rx.controlEvent([.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { _ in
                backView.alpha = 1
            })
            .disposed(by: disposeBag)
    }
    
    func webUrlProvider(_ link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}

func presentBuySubscriptionScreen(presenting: UIViewController) {
    let subscriptionVc = UIStoryboard(name: "IntroBoard", bundle: .main).instantiateViewController(identifier: "BuySubscriptionViewController") as BuySubscriptionViewController
    subscriptionVc.modalPresentationStyle = .fullScreen
    if !isBuySubsPresented {
        presenting.present(subscriptionVc, animated: true, completion: nil)
    }
}

extension UIButton {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
