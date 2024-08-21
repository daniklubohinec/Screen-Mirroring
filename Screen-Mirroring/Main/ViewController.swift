//
//  ViewController.swift
//  Screen-Mirroring
//
//  Created by Danik Lubohinec on 9.08.24.
//

import UIKit
import RxSwift
import AVKit
import Photos

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var connectBackView: UIView!
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var connectImageView: UIImageView!
    @IBOutlet weak var connectButtonTitle: UILabel!
    @IBOutlet weak var connectButtonSubtitle: UILabel!
    
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var filesButton: UIButton!
    
    @IBOutlet weak var howToBackView: UIView!
    @IBOutlet weak var howToTitle: UILabel!
    @IBOutlet weak var howToButton: UIButton!
    private var connected = false
    private let routeView = AVRoutePickerView()
    private var lastStepBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        animateButtonViews()
        setupConnectButtonAction()
        AirPlayDeviceUtility.startMonitoringAirPlayChanges { [weak self] device in
            guard let self else { return }
            if let device = device {
                connectButtonTitle.text = "Active"
                connectButtonSubtitle.text = device
                connectBackView.backgroundColor = R.color.cBF5AF2()
                connectImageView.image = R.image.connectPink()
                howToTitle.text = "How to Disconnect"
                connected = true
                if !isScreenMirroringActive() {
                    BaseViewController.routeDismissed
                        .asObservable()
                        .filter { $0 }
                        .subscribe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { [weak self] _ in
                            HapticGenerator.shared.generateImpact()
                            
                            TipsSheetController.showActionSheet(tipsType: .lastStep)
                            self?.lastStepBag = DisposeBag()
                        })
                        .disposed(by: lastStepBag)
                }
            } else {
                connectButtonTitle.text = "Tap to connect"
                connectButtonSubtitle.text = "Tap to connect and choose another device to pair with your iPhone."
                connectBackView.backgroundColor = R.color.accentColor()
                connectImageView.image = R.image.connect()
                howToTitle.text = "How to Connect"
                connected = false
            }
        }
        NetworkPermissionHelper.shared.requestLocalNetworkPermission(completion: { _ in })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
    }
    
    
    func animateButtonViews() {
        animateButtonView(connectButton, connectBackView, disposeBag)
        animateButtonView(howToButton, howToBackView, disposeBag)
    }
    
    private func setupConnectButtonAction() {
        connectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                HapticGenerator.shared.generateImpact()
                self?.checkWiFiConnection(completion: { [weak self] in
                    self?.routeView.showAirplayView()
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func checkWiFiConnection(completion: (() -> Void)? = nil) {
        if NetworkPermissionHelper.shared.isConnectedToWiFi() {
            if connected {
                completion?()
            } else {
                ActionSheetViewController.showActionSheet(
                    mainImage: R.image.device(),
                    titleText: "Please choose the device you wish to connect to.",
                    subtitleText: "Make sure your devices are connected to the same Wi-Fi network.",
                    firstAction: (
                        action: { [weak self] in
                            self?.routeView.showAirplayView()
                        },
                        image: R.image.airplay(),
                        title: "Open AirPlay"
                        
                    )
                )
            }
        } else {
            ActionSheetViewController.showActionSheet(
                mainImage: R.image.homeWifi(),
                titleText: "Your iPhone is not connected to a Wi-Fi network",
                subtitleText: "Make sure your iPhone is on the same Wi-Fi network as the Cast-enabled device.",
                firstAction: (
                    action: {
                        NetworkPermissionHelper.shared.openWiFiSettings()
                    },
                    image: nil,
                    title: "Turn on Wi-Fi"
                    
                )
            )
        }
    }
    
    @IBAction func howToAction(_ sender: Any) {
        HapticGenerator.shared.generateImpact()
        TipsSheetController.showActionSheet(tipsType: connected ? .disconnect : .connect)
    }
    
    @IBAction
    private func castPhotos() {
        cast(mediaType: .photo)
    }
    
    @IBAction
    private func castVideos() {
        cast(mediaType: .video)
    }
    
    @IBAction
    private func castWeb() {
        HapticGenerator.shared.generateImpact()
        if PurchaseService.shared.hasPremium {
            let controller = WebViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else {
            showPaywall(presenting: self)
        }
    }
    
    @IBAction
    private func openDocuments() {
        HapticGenerator.shared.generateImpact()
        if PurchaseService.shared.hasPremium {
            let vc = DocumentsPickerController(forOpeningContentTypes: [.pdf, .image, .video, .text, .data, .content, .compositeContent])
            vc.didPickDocument = { [weak self] in
                let controller = DocumentViewController(url: $0)
                self?.navigationController?.pushViewController(controller, animated: true)
            }
            present(vc, animated: true)
        } else {
            showPaywall(presenting: self)
        }
    }
    
    private func cast(mediaType: MediaType) {
        HapticGenerator.shared.generateImpact()
        if PurchaseService.shared.hasPremium {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        let vc = AlbumViewController(mediaType: mediaType)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        ActionSheetViewController.showActionSheet(
                            mainImage: R.image.gallery(),
                            titleText: "Allow access to your Photos",
                            subtitleText: "To cast media, allow the app to access Photos in your iPhone Settings.",
                            firstAction: (
                                action: {
                                    BaseViewController.openAppSettings()
                                },
                                image: nil,
                                title: "Go to Settings"
                            )
                        )
                    }
                }
            }
        } else {
            showPaywall(presenting: self)
        }
    }
}

extension AVRoutePickerView {
    func showAirplayView() {
        for view in subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
    }
}
