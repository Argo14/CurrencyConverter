//
//  Configuration.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import UIKit

private var configurationInstane : Configuration? = nil

typealias completionHandler = (_ data: Any,_ responseCode: Int) -> Void


class Configuration: NSObject {
    var infoDictionary : [String : Any]?  = nil
    
    override init() {
        infoDictionary = Bundle.main.infoDictionary
    }
    
    static var shareConfiguration : Configuration
    {
        if configurationInstane == nil
        {
            configurationInstane = Configuration()
        }
        return configurationInstane!
    }
    
    func appName()-> String
    {
        return infoDictionary!["AppName"] as! String
    }
    
    func getVersion() -> String {
        return infoDictionary!["CFBundleShortVersionString"] as! String
    }
}
