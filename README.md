# Currency Converter

An iOS application that allows users to convert currency values in real-time using live exchange rates. This app is structured with the MVVM (Model-View-ViewModel) architecture, promoting a clean separation of concerns and easier maintainability.

## Features

- Real-time currency conversion using the Fixer API.
- User-friendly interface for inputting amounts and selecting currencies.
- Support for multiple currencies with live exchange rates.

## MVVM Architecture

The Currency Converter app follows the **MVVM** design pattern, which promotes separation between the UI and business logic, making the codebase more modular and testable.

### 1. Model

The model represents the data that the app uses. It includes the currency data fetched from the API. The model layer is responsible for decoding the API response.

```swift
struct CurrencyConversionList: Codable {
    let success: Bool
    let base: String
    let rates: [String: Double]
    let base: String
}

struct CurrencyList: Codable {
    let code: String
    let name: String
    let flag: String
}
```
CurrencyConversionList: Holds the exchange rates fetched from the Fixer API.
CurrencyList: Stores information about each country’s currency, including the code, name, and flag.

### 2. ViewModel
The ViewModel interacts with the Model and provides data to the View. It contains all the business logic and manages how data is fetched and manipulated.
```swift
class CurrencyConversionViewModel: NSObject {

    var isSuccess: Observable<Bool?> = Observable(nil)
    var convertedRate: Observable<String?> = Observable(nil)
    var baseCurrencyCode: Observable<String?> = Observable(nil)
    var baseAmount: Observable<String?> = Observable(nil)
    var targetAmount: Observable<String?> = Observable(nil)

    private let apiKey = "your-api-key"
    private let baseURL = "http://data.fixer.io/api/latest"

    func getCurrencyConversionData(baseCurrency: String, targetCurrency: String, baseAmount: String) {
        let urlString = "\(baseURL)?access_key=\(apiKey)"
        ServiceSession.sharedServiceSession.CallApiURLRequest(urlString: urlString) { (jsonResponse, responseCode) in
            do {
                let decoder = JSONDecoder()
                let currencyConversionResponse = try decoder.decode(CurrencyConversionList.self, from: jsonResponse as! Data)

                let sourceRate = currencyConversionResponse.rates[baseCurrency]
                let targetRate = currencyConversionResponse.rates[targetCurrency]

                if let baseAmountDouble = Double(baseAmount), let source = sourceRate, let target = targetRate {
                    let convertedAmount = (baseAmountDouble / source) * target
                    let formattedValue = String(format: "%.2f", convertedAmount)
                    self.convertedRate.value = formattedValue
                }
            } catch {
                self.isSuccess.value = false
            }
        }
    }
}
```
Observable Pattern: Properties such as convertedRate and isSuccess are wrapped in an observable class to allow the view to automatically update when values change.
API Call: The ViewModel fetches the exchange rates from the Fixer API and performs the conversion calculation.

### 3. View
The View (i.e., UIViewController) is responsible for displaying data to the user. It observes the ViewModel for changes and updates the UI accordingly.
```swift
class CurrencyConverterViewController: UIViewController {
    var viewModel = CurrencyConversionViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.convertedRate.bind { [weak self] rate in
            self?.updateConvertedAmount(rate)
        }

        // Trigger the ViewModel to fetch conversion data
        viewModel.getCurrencyConversionData(baseCurrency: "USD", targetCurrency: "INR", baseAmount: "100")
    }

    func updateConvertedAmount(_ rate: String?) {
        // Update UI with the converted amount
    }
}
```
The view binds to observable properties in the ViewModel and updates the UI when data changes.

### API Usage
To use the Fixer API for currency conversion, replace "your-api-key" in the CurrencyConversionViewModel class with your actual API key.

Sample API Request
Here's an example of how the API request is structured:
```swift
let urlString = "\(baseURL)?access_key=\(apiKey)"
```
## Conclusion
Using the MVVM architecture in this app provides a clear separation between data (Model), UI (View), and logic (ViewModel). This structure helps in making the app more scalable, maintainable, and testable.
