//
//  CurrencyConversionViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Arjun Gopakumar on 22/10/24.
//

import XCTest

@testable import CurrencyConverter

final class CurrencyConversionViewModelTests: XCTestCase {

    var viewModel: CurrencyConversionViewModel!
     var mockServiceSession: MockServiceSession!

     override func setUpWithError() throws {
         // Set up mock service session and inject into view model
         mockServiceSession = MockServiceSession()
         viewModel = CurrencyConversionViewModel(serviceSession: mockServiceSession)
     }

     override func tearDownWithError() throws {
         // Clean up
         viewModel = nil
         mockServiceSession = nil
     }

     // Test Success Case for Currency Conversion
     func testCurrencyConversionSuccess() {
         // Given
         let mockController = UIViewController()
         let baseCurrency = "USD"
         let targetCurrency = "INR"
         let baseAmount = "100.0"
         let targetAmount = "0.0"
         let baseFlag = "🇺🇸"
         let convertedFlag = "🇮🇳"

         // When
         let expectation = XCTestExpectation(description: "Currency conversion API success")
         
         mockServiceSession.shouldFail = false // Mock successful response

         viewModel.getCurrencyConversionData(mockController, baseCurrency, targetCurrency, baseAmount, targetAmount, false, baseFlag, convertedFlag, false)

         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             // Then
             XCTAssertEqual(self.viewModel.isSuccess.value, true, "isSuccess should be true on success")
             XCTAssertNotNil(self.viewModel.convertedRate.value, "convertedRate should have a value on success")
             expectation.fulfill()
         }

         wait(for: [expectation], timeout: 2.0)
     }

     // Test Failure Case for Currency Conversion
     func testCurrencyConversionFailure() {
         // Given
         let mockController = UIViewController()
         let baseCurrency = "USD"
         let targetCurrency = "INVALID_CURRENCY"
         let baseAmount = "100.0"
         let targetAmount = "0.0"
         let baseFlag = "🇺🇸"
         let convertedFlag = "🏳️"

         // When
         let expectation = XCTestExpectation(description: "Currency conversion API failure")
         
         mockServiceSession.shouldFail = true // Mock failure response

         viewModel.getCurrencyConversionData(mockController, baseCurrency, targetCurrency, baseAmount, targetAmount, false, baseFlag, convertedFlag, false)

         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             // Then
             XCTAssertEqual(self.viewModel.isSuccess.value, false, "isSuccess should be false on failure")
             expectation.fulfill()
         }

         wait(for: [expectation], timeout: 2.0)
     }
     
     // Test Case for Correctness of Conversion Logic
     func testCorrectnessOfConversion() {
         // Given
         let mockController = UIViewController()
         let baseCurrency = "USD"
         let targetCurrency = "INR"
         let baseAmount = "100.0" // Base amount to convert
         let targetAmount = "0.0"
         let baseFlag = "🇺🇸"
         let convertedFlag = "🇮🇳"

         // Simulated exchange rates
         let usdToInrRate = 75.0
         let usdRate = 1.0 // USD is the base currency with rate 1.0

         // Expected conversion result (baseAmount / usdRate) * usdToInrRate
         let expectedConvertedValue = (Double(baseAmount)! / usdRate) * usdToInrRate
         
         // When
         let expectation = XCTestExpectation(description: "Currency conversion calculation correctness")
         
         // Mock successful response with the rates
         mockServiceSession.shouldFail = false
         mockServiceSession.mockRates = [
             baseCurrency: usdRate, // USD rate is 1.0
             targetCurrency: usdToInrRate // INR rate
         ]

         viewModel.getCurrencyConversionData(mockController, baseCurrency, targetCurrency, baseAmount, targetAmount, false, baseFlag, convertedFlag, false)

         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             // Then
             XCTAssertEqual(self.viewModel.isSuccess.value, true, "isSuccess should be true on success")
             XCTAssertEqual(Double(self.viewModel.convertedRate.value ?? "0.0")!, expectedConvertedValue, accuracy: 0.01, "Converted value should be correct")
             expectation.fulfill()
         }

         wait(for: [expectation], timeout: 2.0)
     }
}
