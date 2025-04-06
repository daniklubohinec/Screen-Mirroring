//
//  OnFlowCastsViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import AVKit
import Photos
import RxSwift

class OnFlowCastsViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var connectBackView: UIView!
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var connectImageView: UIImageView!
    @IBOutlet weak var connectButtonTitle: UILabel! {
        didSet {
            connectButtonTitle.text = "Tap to connect"
        }
    }
    @IBOutlet weak var connectButtonSubtitle: UILabel! {
        didSet {
            connectButtonSubtitle.text = "Tap to connect and choose another device to pair with your iPhone."
        }
    }
    
    @IBOutlet weak var howToBackView: UIView!
    @IBOutlet weak var howToTitle: UILabel! {
        didSet {
            howToTitle.text = "How to Connect"
        }
    }
    @IBOutlet weak var howToButton: UIButton!
    
    @IBOutlet weak var typeOfMirroringCollectionView: UICollectionView!
    
    @IBOutlet weak var castAndCPUSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var circleProgressViewOfCPU: RoundProgressBar! {
        didSet {
            circleProgressViewOfCPU.setProgressColor = UIColor(named: "cBFD2FF") ?? .black
            circleProgressViewOfCPU.setTrackColor = UIColor(named: "c1C1C1E") ?? .white
        }
    }
    
    @IBOutlet weak var cpuUsageLabelText: UILabel! {
        didSet {
            cpuUsageLabelText.font = UIFont(name: "Inter-Bold", size: 46)
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
            usageOfCPUDescritptionLabel.font = UIFont(name: "Inter-Regular", size: 15)
            usageOfCPUDescritptionLabel.text = "CPU usage shows how much of the processor's power is being used by apps and system tasks. High usage can slow performance and drain the battery, while low usage indicates efficient operation."
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
        ScrennCastingDevices.startWatchingScreenCastingChanges { [weak self] device in
            guard let self else { return }
            if let device = device {
                connectButtonTitle.text = "Active"
                connectButtonSubtitle.text = device
                connectBackView.backgroundColor = UIColor(named: "cBF5AF2") ?? .black
                connectImageView.image = UIImage(named: "witouweugg")
                howToTitle.text = "How to Disconnect"
                connected = true
                if !isScreenCastingActive() {
                    StandartTypeViewController.routeDismissed
                        .asObservable()
                        .filter { $0 }
                        .subscribe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { _ in
                            EfficinacyCaller.shared.callHaptic()
                            
                            InAppGuideViewController.showActionSheet(tipsType: .lastStep)
                            self.lastStepBag = DisposeBag()
                        })
                        .disposed(by: lastStepBag)
                }
            } else {
                connectButtonTitle.text = "Tap to connect"
                connectButtonSubtitle.text = "Tap to connect and choose another device to pair with your iPhone."
                connectBackView.backgroundColor = UIColor(named: "c447AF8")
                connectImageView.image = UIImage(named: "erigtjeggg")
                howToTitle.text = "How to Connect"
                connected = false
            }
        }
        NetworkUsagePermissionHelper.shared.requestUserLocalNetworkPermission(completion: { _ in })
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
                EfficinacyCaller.shared.callHaptic()
                self?.checkWiFiConnection(completion: { [weak self] in
                    self?.routeView.showAirplayView()
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func checkWiFiConnection(completion: (() -> Void)? = nil) {
        if NetworkUsagePermissionHelper.shared.isUserConnectToWiFi() {
            if connected {
                completion?()
            } else {
                InAppGuideSheetViewController.showActionSheet(
                    mainImage: UIImage(named: "oewrtiwert"),
                    titleText: "Please choose the device you wish to connect to.",
                    subtitleText: "Make sure your devices are connected to the same Wi-Fi network.",
                    firstAction: (
                        action: { [weak self] in
                            self?.routeView.showAirplayView()
                        },
                        image: UIImage(named: "wegjiwejgi"),
                        title: "Open AirPlay"
                        
                    )
                )
            }
        } else {
            InAppGuideSheetViewController.showActionSheet(
                mainImage: UIImage(named: "iowjergwfCac"),
                titleText: "Your iPhone is not connected to a Wi-Fi network",
                subtitleText: "Make sure your iPhone is on the same Wi-Fi network as the Cast-enabled device.",
                firstAction: (
                    action: {
                        NetworkUsagePermissionHelper.shared.toDeviceWiFiSettings()
                    },
                    image: nil,
                    title: "Turn on Wi-Fi"
                    
                )
            )
        }
    }
    
    @IBAction func howToAction(_ sender: Any) {
        EfficinacyCaller.shared.callHaptic()
        InAppGuideViewController.showActionSheet(tipsType: connected ? .disconnect : .connect)
    }
    
    func cast(mediaType: FileUploaderType) {
        EfficinacyCaller.shared.callHaptic()
        if DomesticPurchasesService.shared.hasPremium {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        let vc = MirrorTypeViewController(mediaType: mediaType)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        InAppGuideSheetViewController.showActionSheet(
                            mainImage: UIImage(named: "dfshdjfvzcxc"),
                            titleText: "Allow access to your Photos",
                            subtitleText: "To cast media, allow the app to access Photos in your iPhone Settings.",
                            firstAction: (
                                action: {
                                    StandartTypeViewController.openAppSettings()
                                },
                                image: nil,
                                title: "Go to Settings"
                            )
                        )
                    }
                }
            }
        } else {
            presentBuySubscriptionScreen(presenting: self)
        }
    }
}
