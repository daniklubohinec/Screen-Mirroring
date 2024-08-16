//
//  ViewController.swift
//  Screen-Mirroring
//
//  Created by Danik Lubohinec on 9.08.24.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var connectBackView: UIView!
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var connectButtonTitle: UILabel!
    @IBOutlet weak var connectButtonSubtitle: UILabel!
    
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var filesButton: UIButton!
    
    @IBOutlet weak var howToBackView: UIView!
    @IBOutlet weak var howToButton: UIButton!
    
    @IBAction func howToAction(_ sender: Any) {
        HapticGenerator.shared.generateImpact()
        
        ActionSheetViewController.showActionSheet(
            mainImage: R.image.device(),
            titleText: "Please choose the device you wish to connect to.",
            subtitleText: "Make sure your devices are connected to the same Wi-Fi network.",
            firstAction: (
                action: {
                    //            // openAppSettings()
                },
                image: nil,
                title: "Open AirPlay"
            
            )
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        animateButtonViews()
    }
    
    func animateButtonViews() {
        animateButtonView(connectButton, connectBackView, disposeBag)
        animateButtonView(howToButton, howToBackView, disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

