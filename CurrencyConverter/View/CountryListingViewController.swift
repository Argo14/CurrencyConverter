//
//  CountryListingViewController.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import UIKit

protocol CurrencyCodeSelectedDelegate{
    func selectedCurrencyCode(_ currencyCode : String,_ countryName : String,_ countryFlag : String, _ isBaseAmount : Bool)
}

class CountryListingViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countryTableView: UITableView!
    
    var searching = false
    var countryListArray : [CurrencyList]?
    var filteredCountryListArray : [CurrencyList]?
    var currencyConversionViewModel : CurrencyConversionViewModel = CurrencyConversionViewModel()
    var delegate : CurrencyCodeSelectedDelegate?
    var isBaseAmountClicked : Bool = true
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        countryTableView.register(UINib.init(nibName: "CountryListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        countryTableView.delegate = self
        countryTableView.dataSource = self
        self.searchBar.delegate = self
        
        getCountryList()
       
    }
    

    
    //MARK: -  load country list from json
    
    func getCountryList(){
        self.countryListArray = self.currencyConversionViewModel.loadCountries()
        self.countryTableView.reloadData()
        
    }
    
    //MARK: -  Dismiss controller by draging down
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)

        if sender.state == UIGestureRecognizer.State.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizer.State.changed {
            print(initialTouchPoint.y)
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizer.State.ended || sender.state == UIGestureRecognizer.State.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.modalPresentationStyle = .overCurrentContext
                self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    


}

extension CountryListingViewController : UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return filteredCountryListArray?.count ?? 0
        }else{
        return countryListArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CountryListTableViewCell
        var dataDict : CurrencyList?
        if searching{
            dataDict = self.filteredCountryListArray![indexPath.row]
        }else{
            dataDict = self.countryListArray![indexPath.row]
        }
        
        cell.countryFlagImageView.imageFromURL(url: URL(string: dataDict?.flag ?? "") ?? URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAG5SURBVHja7JdLihRBEEBfVqUU6rQNggiCFxA8gswFRNy49gAeQdx4G8HbuHDvRkRUnKxPZ2dGhous6Y9TtavPZmITtYggXsWPSKOqrCkFK8stgAFKoOr1kiKAt8CD76/f/KYYj//u7bPpU28Mn199eGiBLabg7uWLUePLp08mB/j66xvA1gKVSkK9J/29guuxNCZrVX60905qZlD0xvd5XbPvmN22uo+XCFDZXI2Idjt0txuk9TFM+ve7Yk9MAkAPIKSuI3XdoEMX/aQAd4qSfYpHAI0RbVt0FGA/KYAtyvMMaBTUObRpBh2a0E3cgspewkkJQkDqGm3bQfNPL9/PtIQ+cmjC5OqbTaj9qppRcglCAFej3h9H8P9xnBUgCtRNBllYDj0QmxbWAkgxggiktFjg60PosAeMJnQtAIkRq7poBlIfK5cgRBQdzYC1dtLgVVVRluUJgEQo7XH0RminlBDCKUDK99AIwByXs4gcb0JJafaFc7aCjTlktQBIqpiVAPIYas5AcXEx6LCRzaxjKAn4465GjZ1zs13GBngMPAceLbyFfwJfTP8m2PR6SfGAM7eP07UB/g0Aw73uXdMbeJMAAAAASUVORK5CYII=")!)
        cell.countryNameLabel.text = dataDict?.country as? String
        cell.countryCurrencyCodeLabel.text = dataDict?.code as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dataDict : CurrencyList?
        if searching{
            dataDict = self.filteredCountryListArray![indexPath.row]
        }else{
            dataDict = self.countryListArray![indexPath.row]
        }
        if self.isBaseAmountClicked{
            delegate?.selectedCurrencyCode(dataDict?.code ?? "", dataDict?.country ?? "", dataDict?.flag ?? "", true )
        }else{
            delegate?.selectedCurrencyCode(dataDict?.code ?? "", dataDict?.country ?? "", dataDict?.flag ?? "", false )
        }
        self.dismiss(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCountryListArray = self.countryListArray!.filter { country in return  country.country.contains(searchText) || country.code.contains(searchText) }
        searching = true
        countryTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        countryTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}
