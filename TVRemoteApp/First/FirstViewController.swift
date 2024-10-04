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
    @IBOutlet weak var connectButtonTitle: UILabel! {
        didSet {
            connectButtonTitle.text = R.string.localizable.tap_To_Connect()
        }
    }
    @IBOutlet weak var connectButtonSubtitle: UILabel! {
        didSet {
            connectButtonSubtitle.text = R.string.localizable.tap_To_Connect_And_Choose_Device()
        }
    }
    
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var filesButton: UIButton!
    
    @IBOutlet weak var howToBackView: UIView!
    @IBOutlet weak var howToTitle: UILabel! {
        didSet {
            howToTitle.text = R.string.localizable.how_To_Connect()
        }
    }
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
            usageOfCPUDescritptionLabel.text = R.string.localizable.cpu_Usage()
        }
    }
    
    private var connected = false
    let routeView = AVRoutePickerView()
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
                connectButtonTitle.text = R.string.localizable.active()
                connectButtonSubtitle.text = device
                connectBackView.backgroundColor = R.color.cBF5AF2()
                connectImageView.image = R.image.mirroringConnectionStatusPink()
                howToTitle.text = R.string.localizable.how_To_Disconnect()
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
                connectButtonTitle.text = R.string.localizable.tap_To_Connect()
                connectButtonSubtitle.text = R.string.localizable.tap_To_Connect_And_Choose_Device()
                connectBackView.backgroundColor = R.color.accentColor()
                connectImageView.image = R.image.mirroringConnectionStatus()
                howToTitle.text = R.string.localizable.how_To_Connect()
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
                    titleText: R.string.localizable.choose_Device(),
                    subtitleText: R.string.localizable.same_WiFi_Network(),
                    firstAction: (
                        action: { [weak self] in
                            self?.routeView.showAirplayView()
                        },
                        image: R.image.openAirPlaySheetButtonImage(),
                        title: R.string.localizable.open_AirPlay()
                        
                    )
                )
            }
        } else {
            BottomSheetTipsPermitViewController.showActionSheet(
                mainImage: R.image.notConnectedToInternetImage(),
                titleText: R.string.localizable.not_Connected_To_WiFi(),
                subtitleText: R.string.localizable.same_WiFi_Network_Message(),
                firstAction: (
                    action: {
                        NetworkPermissionHelper.shared.openWiFiSettings()
                    },
                    image: nil,
                    title: R.string.localizable.turn_On_WiFi()
                    
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
    
    func cast(mediaType: MediaType) {
        HapticGenerator.shared.generateImpact()
        if PurchaseService.shared.hasPremium {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        let vc = AlbumViewController(mediaType: mediaType)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        BottomSheetTipsPermitViewController.showActionSheet(
                            mainImage: R.image.accessPermitionSheetImage(),
                            titleText: R.string.localizable.allow_Access_To_Photos(),
                            subtitleText: R.string.localizable.allow_Photos_Access_Message(),
                            firstAction: (
                                action: {
                                    BaseViewController.openAppSettings()
                                },
                                image: nil,
                                title: R.string.localizable.go_To_Settings()
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
