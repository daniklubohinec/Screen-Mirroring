import UIKit
import QuickLook

final class DocumentsPickerController: UIDocumentPickerViewController {
    var didPickDocument: ((URL) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}
extension DocumentsPickerController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        didPickDocument?(url)
    }
}

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
        self.title = "Document Mirroring"
        
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
                    mainImage: R.image.deviceMirroringSheetMainImage(),
                    titleText: "Please choose the device you wish to connect to.",
                    subtitleText: "Make sure your devices are connected to the same Wi-Fi network.",
                    firstAction: (
                        action: { [weak self] in
                            self?.openAirplayMenu()
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

}
