//
//  CurrencyConversionViewModel.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import UIKit

class CurrencyConversionViewModel: NSObject {

    var isSuccess : Observable<Bool?> = Observable(nil)
    var convertedRate : Observable<String?> = Observable(nil)
    var baseFlag : Observable<String?> = Observable(nil)
    var baseCurrencyCode : Observable<String?> = Observable(nil)
    var convertedFlag : Observable<String?> = Observable(nil)
    var convertedCurrencyCode : Observable<String?> = Observable(nil)
    var baseAmount : Observable<String?> = Observable(nil)
    var targetAmount : Observable<String?> = Observable(nil)
    var indicativeAmount :  Observable<String?> = Observable(nil)
    
    private let apiKey = "e47228bbee42f4b756923f1f254bbafa" // Please add a new api key as this one is exhausted
    private let baseURL = "http://data.fixer.io/api/latest"
    
    // Dependency injection for ServiceSession
       private var serviceSession: ServiceSession

       // Use default ServiceSession for actual app
       init(serviceSession: ServiceSession = ServiceSession.sharedServiceSession) {
           self.serviceSession = serviceSession
       }

    
    func getCurrencyConversionData(_ controller : UIViewController,_ baseCurrency : String,_ targetCurrency : String,_ baseAmount : String,_ targetAmount : String, _ isSwitched : Bool = false,_ baseFlag : String, _ convertedFlag : String,_ isIndicativeConversion : Bool = false){
        
        let urlString = "\(baseURL)?access_key=\(apiKey)"
        
        ServiceSession.sharedServiceSession.CallApiURLRequest(controller: controller, urlString: urlString){ (jsonResponse, responseCode) in
            
            do{
                let decoder = JSONDecoder()
                let currencyConversionResponse = try decoder.decode(CurrencyConversionList.self, from: jsonResponse as! Data)
                self.isSuccess.value = true
                

                if isSwitched{
                    self.baseCurrencyCode.value = targetCurrency
                    self.baseFlag.value = convertedFlag
                    self.convertedFlag.value = baseFlag
                    self.convertedCurrencyCode.value = baseCurrency
                    self.baseAmount.value = targetAmount
                    
                    
                    let baseAmountDouble = Double(targetAmount)
                    
                    let sourceRate = currencyConversionResponse.rates[targetCurrency]
                    let targetRate = currencyConversionResponse.rates[baseCurrency]
                    
                    if isIndicativeConversion{
                        let convertedAmount = ((1 ) / (sourceRate ?? 0.0) ) * (targetRate ?? 0.0)
                        let formattedValue = String(format: "%.2f", convertedAmount)
                        self.indicativeAmount.value = formattedValue
                    }else{
                        let convertedAmount = ((baseAmountDouble ?? 0.0) / (sourceRate ?? 0.0) ) * (targetRate ?? 0.0)
                        let formattedValue = String(format: "%.2f", convertedAmount)
                        self.convertedRate.value = formattedValue
                    }
                    
                   
                        
                    
                    
                }else{
                    
                    let baseAmountDouble = Double(baseAmount)
                    
                    let sourceRate = currencyConversionResponse.rates[baseCurrency]
                    let targetRate = currencyConversionResponse.rates[targetCurrency]
                    
                    if isIndicativeConversion{
                        let convertedAmount = ((1 ) / (sourceRate ?? 0.0) ) * (targetRate ?? 0.0)
                        let formattedValue = String(format: "%.2f", convertedAmount)
                        self.indicativeAmount.value = formattedValue
                    }else{
                        let convertedAmount = ((baseAmountDouble ?? 0.0) / (sourceRate ?? 0.0) ) * (targetRate ?? 0.0)
                        let formattedValue = String(format: "%.2f", convertedAmount)
                        self.convertedRate.value = formattedValue
                    }
                }
                
            } catch {
                self.isSuccess.value = false
            }
            
            
        }
        
    }
    

    
    func getLocaleCurrency() -> String{
        
        // Fetch the users local currency
        let locale = Locale.current
        
        
        
        return locale.currency?.identifier ?? "INR"
    }
    
    
    func loadCountries() -> [CurrencyList]? {
        
        guard let url = Bundle.main.url(forResource: "currencies-with-flags", withExtension: "json") else {
               print("Failed to locate the json in bundle.")
               return nil
           }

           do {
               // Load the data from the JSON file
               let data = try Data(contentsOf: url)
               
               // Decode the data into an array of Country objects
               let decoder = JSONDecoder()
               let countries = try decoder.decode([CurrencyList].self, from: data)
               
               return countries
           } catch {
               print("Failed to decode JSON: \(error.localizedDescription)")
               return nil
           }
        
    }

    
}
