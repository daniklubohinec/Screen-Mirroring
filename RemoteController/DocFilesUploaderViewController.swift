//
//  DocFilesUploaderViewController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import QuickLook

final class DocFilesUploaderViewController: StandartTypeViewController, QLPreviewControllerDataSource {
    
    private let documentURL: URL
    private let previewController = QLPreviewController()
    
    private enum Images {
        static let airplay = "wegjiwejgi"
        static let deviceSelection = "oewrtiwert"
        static let wifiWarning = "iowjergwfCac"
    }
    
    // MARK: - Init
    
    init(url: URL) {
        self.documentURL = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupPreviewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.checkConnection()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigationBar() {
        title = "Document Mirroring"
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setupPreviewController() {
        previewController.dataSource = self
        addChild(previewController)
        view.addSubview(previewController.view)
        
        previewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        previewController.didMove(toParent: self)
        previewController.reloadData()
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURL as QLPreviewItem
    }
    
    // MARK: - Connectivity Check
    
    private func checkConnection() {
        guard NetworkUsagePermissionHelper.shared.isUserConnectToWiFi() else {
            showActionSheet(
                title: "Your iPhone is not connected to a Wi-Fi network",
                subtitle: "Make sure your iPhone is on the same Wi-Fi network as the Cast-enabled device.",
                image: UIImage(named: Images.wifiWarning),
                actionTitle: "Turn on Wi-Fi",
                action: { NetworkUsagePermissionHelper.shared.toDeviceWiFiSettings() }
            )
            return
        }
        
        if !ScrennCastingDevices.connected {
            showActionSheet(
                title: "Please choose the device you wish to connect to.",
                subtitle: "Make sure your devices are connected to the same Wi-Fi network.",
                image: UIImage(named: Images.deviceSelection),
                actionTitle: "Open AirPlay",
                action: { [weak self] in self?.openAirplayMenu() }
            )
        }
    }
    
    // MARK: - Bottom Sheet Helper
    
    private func showActionSheet(title: String, subtitle: String, image: UIImage?, actionTitle: String, action: @escaping () -> Void) {
        InAppGuideSheetViewController.showActionSheet(
            mainImage: image,
            titleText: title,
            subtitleText: subtitle,
            firstAction: (action: action, image: UIImage(named: Images.airplay), title: actionTitle)
        )
    }
}

