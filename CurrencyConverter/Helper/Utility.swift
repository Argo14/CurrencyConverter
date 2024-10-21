//
//  Utility.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import UIKit
import SystemConfiguration

struct sharedInstance {
    static let instance = Utility()
}

// Check if this is needed or if not remove

protocol UtilityProtocol {
    
    func dismissAlert()
    func pushToViewController()
    func pushToNextViewController()
}



private var utilityInstance: Utility? = nil

class Utility: NSObject {
    
    var spinner = UIActivityIndicatorView(style: .large)
    
    var delegate:UtilityProtocol? = nil
    static var sharedUtility : Utility {

        if utilityInstance == nil {
            utilityInstance = Utility()
        }
        return utilityInstance!
    }
    
    class var sharedInstance : Utility {
        struct sharedInstance {
            static let instance = Utility()
        }
        return sharedInstance.instance
    }
    
    // MARK: - Network
    func isInternetAvailable() -> Bool
    {
        // Update to address IPv6 requirements
        let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "https://google.com")
        
        var flags : SCNetworkReachabilityFlags = SCNetworkReachabilityFlags()
        
        if SCNetworkReachabilityGetFlags(reachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
        
    }
    
    // MARK: - Activity Indicator
    func showActivity(view:UIView)
    {
        
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
    }
    // stop activity
    func stopActivity(view:UIView)
    {
        spinner.stopAnimating()
        view.removeFromSuperview()
    }
    
    // Alert View
    func showAlertViewWithTitle(_ title: String, with message: String,controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    

}

// Download image from URL
extension UIImageView {
    public func imageFromURL(url: URL, isLoaderRequired:Bool = true) {
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.contentMode = self.contentMode
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
        self.image = UIImage(named: "mediaThumbnail")
        if(!isLoaderRequired)
        {
            activityIndicator.isHidden = true
        }
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let ImageViewVerticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let ImageViewHorizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([ImageViewVerticalConstraint, ImageViewHorizontalConstraint])
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                
                activityIndicator.removeFromSuperview()
                self.image = image
            })
            
        }).resume()
    }
    
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}


@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}
