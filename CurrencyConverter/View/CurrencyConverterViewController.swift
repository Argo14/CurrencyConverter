//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import UIKit

class CurrencyConverterViewController: UIViewController {
    
    @IBOutlet weak var amountTextField: UITextField!{
        didSet{
            let toolbar = UIToolbar()
            toolbar.sizeToFit()

            // Create the "Done" button
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
            toolbar.setItems([doneButton], animated: false)

            // Assign the toolbar to the inputAccessoryView of the text field
            amountTextField.inputAccessoryView = toolbar
        
        let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
            amountTextField.rightView = rightView
            amountTextField.rightViewMode = .always
            
            amountTextField.contentHorizontalAlignment = .right
        


        }
    }
    
    @IBOutlet weak var convertedAmountTextField: UITextField!{
        didSet{
  
        let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 2.0))
            convertedAmountTextField.rightView = rightView
            convertedAmountTextField.rightViewMode = .always
            
        }
    }
    
    @IBOutlet weak var switchConversionButton: UIButton!
    
    @IBOutlet weak var amountCurrencyButton: UIButton!
    
    @IBOutlet weak var convertedAmountCurrencyButton: UIButton!
    
    @IBOutlet weak var indicativeExchangeRateLabel: UILabel!
    
    @IBOutlet weak var amountFlagImageView: UIImageView!
    
    @IBOutlet weak var amountCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var convertedAmountCurrencyCodeLabel: UILabel!
    
    @IBOutlet weak var convertedAmountFlagImageView: UIImageView!
    
    
    
    var apiCallDelayTimer: Timer?
    var currencyConversionViewModel : CurrencyConversionViewModel = CurrencyConversionViewModel()
    var baseFlag : String?
    var convertedFlag : String?
    var updatedText : String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.amountTextField.delegate = self
        self.convertedAmountTextField.delegate = self
        
            
        getLocaleCurrency()
        getIndicativeApi()
    }
    
    // Dismiss the keyboard when "Done" is tapped
     @objc func dismissKeyboard() {
         self.amountTextField.resignFirstResponder()
     }
    
    //MARK: - Fetch local currency
    
    func getLocaleCurrency(){
       let localCurrency =  self.currencyConversionViewModel.getLocaleCurrency()
        let countryArray = self.currencyConversionViewModel.loadCountries()
        
        let findCountry: (String) -> CurrencyList? = { currencyCode in
            return countryArray?.first { $0.code == currencyCode }
           }
        
        if let country = findCountry(localCurrency){
            self.amountCurrencyCodeLabel.text = country.code
            self.amountFlagImageView.imageFromURL(url: URL(string: country.flag) ?? URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAG5SURBVHja7JdLihRBEEBfVqUU6rQNggiCFxA8gswFRNy49gAeQdx4G8HbuHDvRkRUnKxPZ2dGhous6Y9TtavPZmITtYggXsWPSKOqrCkFK8stgAFKoOr1kiKAt8CD76/f/KYYj//u7bPpU28Mn199eGiBLabg7uWLUePLp08mB/j66xvA1gKVSkK9J/29guuxNCZrVX60905qZlD0xvd5XbPvmN22uo+XCFDZXI2Idjt0txuk9TFM+ve7Yk9MAkAPIKSuI3XdoEMX/aQAd4qSfYpHAI0RbVt0FGA/KYAtyvMMaBTUObRpBh2a0E3cgspewkkJQkDqGm3bQfNPL9/PtIQ+cmjC5OqbTaj9qppRcglCAFej3h9H8P9xnBUgCtRNBllYDj0QmxbWAkgxggiktFjg60PosAeMJnQtAIkRq7poBlIfK5cgRBQdzYC1dtLgVVVRluUJgEQo7XH0RminlBDCKUDK99AIwByXs4gcb0JJafaFc7aCjTlktQBIqpiVAPIYas5AcXEx6LCRzaxjKAn4465GjZ1zs13GBngMPAceLbyFfwJfTP8m2PR6SfGAM7eP07UB/g0Aw73uXdMbeJMAAAAASUVORK5CYII=")! )
            
            let findCountryUS: (String) -> CurrencyList? = { currencyCode in
                return countryArray?.first { $0.code == "USD" }
               }
            if let country = findCountryUS(localCurrency){
                self.convertedAmountCurrencyCodeLabel.text = country.code
                self.convertedAmountFlagImageView.imageFromURL(url: URL(string: country.flag) ?? URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAG5SURBVHja7JdLihRBEEBfVqUU6rQNggiCFxA8gswFRNy49gAeQdx4G8HbuHDvRkRUnKxPZ2dGhous6Y9TtavPZmITtYggXsWPSKOqrCkFK8stgAFKoOr1kiKAt8CD76/f/KYYj//u7bPpU28Mn199eGiBLabg7uWLUePLp08mB/j66xvA1gKVSkK9J/29guuxNCZrVX60905qZlD0xvd5XbPvmN22uo+XCFDZXI2Idjt0txuk9TFM+ve7Yk9MAkAPIKSuI3XdoEMX/aQAd4qSfYpHAI0RbVt0FGA/KYAtyvMMaBTUObRpBh2a0E3cgspewkkJQkDqGm3bQfNPL9/PtIQ+cmjC5OqbTaj9qppRcglCAFej3h9H8P9xnBUgCtRNBllYDj0QmxbWAkgxggiktFjg60PosAeMJnQtAIkRq7poBlIfK5cgRBQdzYC1dtLgVVVRluUJgEQo7XH0RminlBDCKUDK99AIwByXs4gcb0JJafaFc7aCjTlktQBIqpiVAPIYas5AcXEx6LCRzaxjKAn4465GjZ1zs13GBngMPAceLbyFfwJfTP8m2PR6SfGAM7eP07UB/g0Aw73uXdMbeJMAAAAASUVORK5CYII=")! )
            }
        }
    }
    
    
    //MARK: - Api call and observers
    
    func getIndicativeApi(_ isSwitched : Bool = false){
        
        self.currencyConversionViewModel.getCurrencyConversionData(self,self.amountCurrencyCodeLabel.text ?? "" , self.convertedAmountCurrencyCodeLabel.text ?? "", "1", self.convertedAmountTextField.text ?? "0", isSwitched, self.baseFlag ?? "", self.convertedFlag ?? "", true)
        getIndicativeApiObserver()
    }
    
    func getIndicativeApiObserver(){
        DispatchQueue.main.async {
            self.currencyConversionViewModel.indicativeAmount.bind{ response in
                self.indicativeExchangeRateLabel.text = "1 \(self.amountCurrencyCodeLabel.text ?? "USD") = \(response ?? "0") \(self.convertedAmountCurrencyCodeLabel.text ?? "USD") "
            }
            
        }
    }
    
    func getConversion(_ amount : String, isSwitched : Bool = false){
        

        self.currencyConversionViewModel.getCurrencyConversionData(self,self.amountCurrencyCodeLabel.text ?? "" , self.convertedAmountCurrencyCodeLabel.text ?? "", self.amountTextField.text ?? "", self.convertedAmountTextField.text ?? "0", isSwitched, self.baseFlag ?? "", self.convertedFlag ?? "")
           
        getConversionObservable(isSwitched)

        self.getIndicativeApi(isSwitched)

       
    }
    
    func getConversionObservable(_ isSwitched : Bool = false){
        self.currencyConversionViewModel.isSuccess.bind{ response in
            
            switch response{
            case true:
                if isSwitched{
                    DispatchQueue.main.async {
                        self.currencyConversionViewModel.baseFlag.bind{ response in
                          
                            if response != nil{
                                self.amountFlagImageView.imageFromURL(url: URL(string: response ?? "") ?? URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAG5SURBVHja7JdLihRBEEBfVqUU6rQNggiCFxA8gswFRNy49gAeQdx4G8HbuHDvRkRUnKxPZ2dGhous6Y9TtavPZmITtYggXsWPSKOqrCkFK8stgAFKoOr1kiKAt8CD76/f/KYYj//u7bPpU28Mn199eGiBLabg7uWLUePLp08mB/j66xvA1gKVSkK9J/29guuxNCZrVX60905qZlD0xvd5XbPvmN22uo+XCFDZXI2Idjt0txuk9TFM+ve7Yk9MAkAPIKSuI3XdoEMX/aQAd4qSfYpHAI0RbVt0FGA/KYAtyvMMaBTUObRpBh2a0E3cgspewkkJQkDqGm3bQfNPL9/PtIQ+cmjC5OqbTaj9qppRcglCAFej3h9H8P9xnBUgCtRNBllYDj0QmxbWAkgxggiktFjg60PosAeMJnQtAIkRq7poBlIfK5cgRBQdzYC1dtLgVVVRluUJgEQo7XH0RminlBDCKUDK99AIwByXs4gcb0JJafaFc7aCjTlktQBIqpiVAPIYas5AcXEx6LCRzaxjKAn4465GjZ1zs13GBngMPAceLbyFfwJfTP8m2PR6SfGAM7eP07UB/g0Aw73uXdMbeJMAAAAASUVORK5CYII=")!)
                                self.baseFlag = response
                            }
                        }
                        self.currencyConversionViewModel.convertedFlag.bind{ response in
                            if response != nil{
                                self.convertedAmountFlagImageView.imageFromURL(url: URL(string: response ?? "") ?? URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAG5SURBVHja7JdLihRBEEBfVqUU6rQNggiCFxA8gswFRNy49gAeQdx4G8HbuHDvRkRUnKxPZ2dGhous6Y9TtavPZmITtYggXsWPSKOqrCkFK8stgAFKoOr1kiKAt8CD76/f/KYYj//u7bPpU28Mn199eGiBLabg7uWLUePLp08mB/j66xvA1gKVSkK9J/29guuxNCZrVX60905qZlD0xvd5XbPvmN22uo+XCFDZXI2Idjt0txuk9TFM+ve7Yk9MAkAPIKSuI3XdoEMX/aQAd4qSfYpHAI0RbVt0FGA/KYAtyvMMaBTUObRpBh2a0E3cgspewkkJQkDqGm3bQfNPL9/PtIQ+cmjC5OqbTaj9qppRcglCAFej3h9H8P9xnBUgCtRNBllYDj0QmxbWAkgxggiktFjg60PosAeMJnQtAIkRq7poBlIfK5cgRBQdzYC1dtLgVVVRluUJgEQo7XH0RminlBDCKUDK99AIwByXs4gcb0JJafaFc7aCjTlktQBIqpiVAPIYas5AcXEx6LCRzaxjKAn4465GjZ1zs13GBngMPAceLbyFfwJfTP8m2PR6SfGAM7eP07UB/g0Aw73uXdMbeJMAAAAASUVORK5CYII=")!)
                                self.convertedFlag = response
                            }
                        }
                        self.currencyConversionViewModel.baseCurrencyCode.bind{ response in
                            self.amountCurrencyCodeLabel.text = response
                        }
                        self.currencyConversionViewModel.convertedCurrencyCode.bind{ response in
                            self.convertedAmountCurrencyCodeLabel.text = response
                        }
                        self.currencyConversionViewModel.baseAmount.bind{ response in
                            self.amountTextField.text = response
                        }
                        
                       
  
                    }
                }else{
                    
                }
                
                    DispatchQueue.main.async {
                        self.currencyConversionViewModel.convertedRate.bind{ response in
                        self.convertedAmountTextField.text = response
                           
                        }
                        
                    }
                
                
            case false:
                break
            default:
                break
            }
            
        }
    }

    
    //MARK: - Button actions
    
    @IBAction func currencySwitchButtonClicked(_ sender: Any) {
        
        self.getConversion( self.amountTextField.text ?? "", isSwitched: true)
        
  
        
    }
    
    @IBAction func amountCurrencyButtonClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "CountryListingViewController") as! CountryListingViewController

        VC.delegate = self
        VC.isBaseAmountClicked = true
        VC.modalPresentationStyle = .overFullScreen
        VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(VC, animated: true)
        
        
    }
    
    
    @IBAction func convertedAmountCurrencyButtonClicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "CountryListingViewController") as! CountryListingViewController

        VC.delegate = self
        VC.isBaseAmountClicked = false
        VC.modalPresentationStyle = .overFullScreen
        VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(VC, animated: true)
    }
    
    
    
    

   
}


extension CurrencyConverterViewController : UITextFieldDelegate, CurrencyCodeSelectedDelegate {
    func selectedCurrencyCode(_ currencyCode: String, _ countryName: String, _ countryFlag: String, _ isBaseAmount: Bool) {
        if isBaseAmount{
  
            self.amountCurrencyCodeLabel.text = currencyCode
            self.amountFlagImageView.imageFromURL(url: URL(string: countryFlag)!)
            self.baseFlag = countryFlag
        }else{
            
            self.convertedAmountCurrencyCodeLabel.text = currencyCode
            self.convertedAmountFlagImageView.imageFromURL(url: URL(string: countryFlag)!)
            self.convertedFlag = countryFlag
        }
        self.getConversion(self.updatedText,isSwitched: false)
        getIndicativeApi()
    }
    
    

    
    //MARK: - Textfield delegates
    

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text as NSString? {
            let updatedText = text.replacingCharacters(in: range, with: string)
            print("Current input: \(updatedText)")
            
            // Reset any previously scheduled API call
            apiCallDelayTimer?.invalidate()
            
            // Call the API after a delay of 1 second
            apiCallDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                self.updatedText = updatedText
                self.getConversion(updatedText,isSwitched: false)
                
            }
            
          
        }
        
        
        return true
    }
    
    
    
}
