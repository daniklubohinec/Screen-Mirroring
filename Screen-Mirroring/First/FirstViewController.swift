//
//  FirstViewController.swift
//  Screen-Mirroring
//
//  Created by Liver Pauler on 08.01.24.
//

import UIKit
import RxSwift
import AVKit
import Photos

class FirstViewController: UIViewController {
    
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
    
    @IBOutlet weak var typeOfMirroringCollectionView: UICollectionView!
    
    @IBOutlet weak var castAndCPUSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var circleProgressViewOfCPU: CircularProgressView! {
        didSet {
            circleProgressViewOfCPU.setProgressColor = R.color.cBFD2FF() ?? .black
            circleProgressViewOfCPU.setTrackColor = R.color.c1C1C1E() ?? .white
        }
    }
    
    @IBOutlet weak var cpuUsageLabelText: UILabel! {
        didSet {
            cpuUsageLabelText.font = R.font.interBold(size: 46)
        }
    }
    
    @IBOutlet weak var usageOfCPUBackView: UIView!
    
    @IBAction func segmentControlTapAction(_ sender: Any) {
        switch castAndCPUSegmentedControl.selectedSegmentIndex {
        case 0:
            usageOfCPUBackView.isHidden = true
        case 1:
            usageOfCPUBackView.isHidden = false
            cpuUsage()
        default:
            break;
        }
    }
    
    @IBOutlet weak var usageOfCPUDescritptionLabel: UILabel! {
        didSet {
            usageOfCPUDescritptionLabel.font = R.font.interRegular(size: 15)
        }
    }
    
    
    private var connected = false
    private let routeView = AVRoutePickerView()
    private var lastStepBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        typeOfMirroringCollectionView.delegate = self
        typeOfMirroringCollectionView.dataSource = self
        
        cpuUsage()
        
        usageOfCPUBackView.isHidden = true
        
        animateButtonViews()
        setupConnectButtonAction()
        AirPlayDeviceUtility.startMonitoringAirPlayChanges { [weak self] device in
            guard let self else { return }
            if let device = device {
                connectButtonTitle.text = "Active"
                connectButtonSubtitle.text = device
                connectBackView.backgroundColor = R.color.cBF5AF2()
                connectImageView.image = R.image.mirroringConnectionStatusPink()
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
                connectImageView.image = R.image.mirroringConnectionStatus()
                howToTitle.text = "How to Connect"
                connected = false
            }
        }
        NetworkPermissionHelper.shared.requestLocalNetworkPermission(completion: { _ in })
    }
    
    
    
    func cpuUsage() {
        var totalUsageOfCPU: Double = 0.0
        var threadsList = UnsafeMutablePointer(mutating: [thread_act_t]())
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }
        
        if threadsResult == KERN_SUCCESS {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }
                
                guard infoResult == KERN_SUCCESS else {
                    break
                }
                
                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 1.0))
                }
            }
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
        circleProgressViewOfCPU.setProgressWithAnimation(duration: 0.6, value: Float(totalUsageOfCPU))
        
        let floatUsage = Float(totalUsageOfCPU) * 100
        let roundedUsageOfCPU = Int(floatUsage.rounded(.toNearestOrEven)) + 7
        
        cpuUsageLabelText.text = "\(roundedUsageOfCPU)%"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.black
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
                BottomSheetTipsPermitViewController.showActionSheet(
                    mainImage: R.image.deviceMirroringSheetMainImage(),
                    titleText: "Please choose the device you wish to connect to.",
                    subtitleText: "Make sure your devices are connected to the same Wi-Fi network.",
                    firstAction: (
                        action: { [weak self] in
                            self?.routeView.showAirplayView()
                        },
                        image: R.image.openAirPlaySheetButtonImage(),
                        title: "Open AirPlay"
                        
                    )
                )
            }
        } else {
            BottomSheetTipsPermitViewController.showActionSheet(
                mainImage: R.image.notConnectedToInternetImage(),
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
        let controller = WebViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction
    private func openDocuments() {
        HapticGenerator.shared.generateImpact()
        let vc = DocumentsPickerController(forOpeningContentTypes: [.pdf, .image, .video, .text, .data, .content, .compositeContent])
        vc.didPickDocument = { [weak self] in
            let controller = DocumentViewController(url: $0)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        present(vc, animated: true)
    }
    
    func cast(mediaType: MediaType) {
        HapticGenerator.shared.generateImpact()
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                if status == .authorized {
                    let vc = AlbumViewController(mediaType: mediaType)
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else {
                    BottomSheetTipsPermitViewController.showActionSheet(
                        mainImage: R.image.accessPermitionSheetImage(),
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
