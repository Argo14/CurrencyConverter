//
//  ServiceSession.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import UIKit

private var serviceSessionInstance :ServiceSession? = nil

let kPost = "POST"
let kPut = "PUT"
let kGet = "GET"
let kDelete = "DELETE"


struct HTTPResponse {
    static let kSuccess = 200
    static let kCreated = 201
    static let kUnauthorized = 401
    static let kForbidden = 403
    static let kNotFound = 404
    static let kNotAvailable = 400
    static let kServerError = 500
}


class ServiceSession: NSObject {
    
    
    
    static var sharedServiceSession : ServiceSession {
        if serviceSessionInstance == nil {
            serviceSessionInstance = ServiceSession()
        }
        return serviceSessionInstance!
    }
    
    let session  = URLSession.shared
    var urlRequest: URLRequest! = nil
    
    func CallApiURLRequest(controller: UIViewController, urlString: String, isLoadingInBackground:Bool = true, completionHandler: @escaping completionHandler) {
        

        if let url = URL(string: urlString) {
            
            if !Utility.sharedUtility.isInternetAvailable() {
                internetNotAvailableAlertView(controller: controller)
                return
            }
 
            urlRequest = URLRequest(url: url)

            
            session.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
    
                if data == nil && error == nil {
                    self.internalServerErrorAlertView(controller: controller)
                    return
                } else if error != nil {
                    print("fail to connect with error:\((error?.localizedDescription)!)")
                    self.errorAlertView(controller: controller, error: error! as NSError)
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:[])
                    DispatchQueue.main.async {
                        self.handleServerResponse(response: json as? NSDictionary, controller: controller) { (status,responseCode) in
                            if status {
                                completionHandler(data!,responseCode)
                            }else{
                                completionHandler(NSDictionary(),responseCode)
                            }
                        }
                    }
                } catch {
                    print("failed to Get Data from Server with error:%@",error)
                    self.errorAlertView(controller: controller, error: error as NSError)
                    
                }
                
            }).resume()
        }
    }
    
    
    // MARK: - Handle Server Response
    func handleServerResponse(response:NSDictionary? ,controller: UIViewController, completionHandler: @escaping (Bool,Int)-> Void) {
       
        if response?["success"] != nil{
            if response?["success"] as? Bool == true{
                completionHandler(true, 200)
            }else{
                
                
                Utility.sharedUtility.showAlertViewWithTitle("Warning", with: "The server seems to be down at the moment, Please try again after some time. Sorry for the inconvenience " , controller: controller)
                
            }
        }
        

    }
    
    //MARKS:- Show Response
    func internetNotAvailableAlertView(controller: UIViewController) {
        DispatchQueue.main.async(execute: {
            Utility.sharedUtility.showAlertViewWithTitle("Warning", with: "The Internet connection appears to be offline", controller: controller)
        })
    }
    
    func internalServerErrorAlertView(controller: UIViewController)  {
        DispatchQueue.main.async(execute: {
            Utility.sharedUtility.showAlertViewWithTitle("Warning", with: "Internal server error", controller: controller)
        })
    }
    
    func errorAlertView(controller: UIViewController, error: NSError?) {
        DispatchQueue.main.async(execute: {
            Utility.sharedUtility.showAlertViewWithTitle("Warning", with: (error?.localizedDescription)!, controller: controller)
        })
    }
    
}

// Mock service session
class MockServiceSession: ServiceSession {
    
    var shouldFail: Bool = false
    var mockRates: [String: Double]? = nil

     func CallApiURLRequest(controller: UIViewController, urlString: String, completion: @escaping (Any?, Int) -> Void) {
        if shouldFail {
            completion(nil, 400) // Simulate failure
        } else {
            // Use mock rates if provided
            if let rates = mockRates {
                let jsonResponse = try? JSONSerialization.data(withJSONObject: ["rates": rates], options: [])
                completion(jsonResponse, 200)
            } else {
                let defaultJsonResponse = """
                {
                    "rates": {
                        "USD": 1.0,
                        "INR": 75.0
                    }
                }
                """.data(using: .utf8)
                completion(defaultJsonResponse, 200) // Simulate success
            }
        }
    }
}
