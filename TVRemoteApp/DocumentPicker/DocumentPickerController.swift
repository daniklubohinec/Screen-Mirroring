import UIKit

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
