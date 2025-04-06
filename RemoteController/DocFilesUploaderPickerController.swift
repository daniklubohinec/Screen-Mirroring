//
//  DocFilesUploaderPickerController.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit

final class DocFilesUploaderPickerController: UIDocumentPickerViewController, UIDocumentPickerDelegate {
    var didPickDocument: ((URL) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        didPickDocument?(url)
    }
}

