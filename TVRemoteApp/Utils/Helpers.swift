import Foundation
import UIKit
import Photos
import AVFoundation

extension UIColor {
    func hexStringFromColor() -> String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        if a == 1.0 {
            // If the alpha channel is 1, return the HEX code without the alpha value
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        } else {
            // If the alpha channel is not 1, include the alpha value
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        }
    }

    static func colorWithHexString(hexString: String) -> UIColor {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count == 6 {
            cString.append("FF") // Add alpha value if not provided
        }

        if cString.count != 8 {
            return UIColor.gray // Return gray color if the string is invalid
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
            alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
        )
    }
}

func onMain(f: @escaping (() -> Void)) {
    DispatchQueue.main.async {
        f()
    }
}

extension UIView {
    func applyGradientMask() {
        clipsToBounds = true
        if let mask = self.layer.mask {
            mask.frame = self.bounds
        } else {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.bounds

            // Настройка цветов градиента
            // gradientLayer.colors = [R.color.cF1F1F1()!.cgColor, UIColor.clear.cgColor]
            gradientLayer.locations = [0.0, 0.4] // Начало и конец градиента

            // Настройка направления градиента
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

            // Создание маски из градиентного слоя
            self.layer.mask = gradientLayer
        }
    }
}

func openAppSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension UIViewController {
    func presentWithFade(_ viewControllerToPresent: UIViewController, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .overFullScreen
        viewControllerToPresent.view.alpha = 0.0
        
        self.present(viewControllerToPresent, animated: false) {
            UIView.animate(withDuration: duration, animations: {
                viewControllerToPresent.view.alpha = 1.0
            }, completion: { finished in
                completion?()
            })
        }
    }
}

func share(
    text: String,
    onViewController: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
) {
    let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    activityViewController.excludedActivityTypes = [
        .assignToContact,
        .addToReadingList
    ]
    
    onViewController?.present(activityViewController, animated: true, completion: nil)
}

func presentGlobally(controller: UIViewController) {
    if let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
        let presentOn: UIViewController?
        if root is FirstViewController {
            presentOn = root.presentedViewController ?? root.children.first
        } else {
            presentOn = root
        }
        presentOn?.present(controller, animated: true)
    }
}

final class AirPlayDeviceUtility {
    private init() { }
    static var connected = false
    
    static func getCurrentAirPlayDevice() -> String? {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        for output in currentRoute.outputs {
            if output.portType == AVAudioSession.Port.airPlay {
                return output.portName
            }
        }

        return nil
    }
    
    static func startMonitoringAirPlayChanges(callback: @escaping (String?) -> Void) {
        NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
            }
            
            switch reason {
            case .newDeviceAvailable, .oldDeviceUnavailable, .override:
                // The route has changed, so check for the current AirPlay device
                let currentDevice = getCurrentAirPlayDevice()
                connected = currentDevice != nil
                callback(currentDevice)
                if !isScreenMirroringActive() {
                    
                }
            default:
                break
            }
        }
    }
    
    static func stopMonitoringAirPlayChanges() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
}

func isScreenMirroringActive() -> Bool {
    let sessions = UIApplication.shared.openSessions
    for session in sessions {
        if let screen = (session.scene as? UIWindowScene)?.screen, screen.mirrored != nil {
            return true
        }
    }
    return false
}
