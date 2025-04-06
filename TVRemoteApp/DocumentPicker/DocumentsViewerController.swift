import UIKit
import QuickLook

final class DocumentViewController: BaseViewController, QLPreviewControllerDataSource {

    private let documentURL: URL
    private let previewController = QLPreviewController()
    
    init(url: URL) {
        self.documentURL = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize your navigation bar here
        self.title = R.string.localizable.document_Mirroring()
        
        // Configure the preview controller
        previewController.dataSource = self
        
        // Add the preview controller as a child
        addChild(previewController)
        view.addSubview(previewController.view)
        
        // Use SnapKit to layout the preview controller's view
        previewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        previewController.didMove(toParent: self)
        previewController.reloadData()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.checkConnection()
        }
    }
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURL as QLPreviewItem
    }
    
    private func checkConnection() {
        if NetworkPermissionHelper.shared.isConnectedToWiFi() {
            if !AirPlayDeviceUtility.connected {
                BottomSheetTipsPermitViewController.showActionSheet(
                    mainImage: R.image.mainScreen.deviceMirroringIcon(),
                    titleText: R.string.localizable.choose_Device(),
                    subtitleText: R.string.localizable.same_WiFi_Network_Message(),
                    firstAction: (
                        action: { [weak self] in
                            self?.openAirplayMenu()
                        },
                        image: R.image.mainScreen.openAirPlaySheetButtonImage(),
                        title: R.string.localizable.open_AirPlay()
                    
                    )
                )
            }
        } else {
            BottomSheetTipsPermitViewController.showActionSheet(
                mainImage: R.image.mainScreen.notConnectedToInternetImage(),
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

}
