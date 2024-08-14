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
    
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var filesButton: UIButton!
    
    @IBAction func settingsButtonAction(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        animateButtonViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func animateButtonViews() {
        animateButtonView(connectButton, connectBackView, disposeBag)
    }
}

