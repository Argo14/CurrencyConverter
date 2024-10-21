//
//  CurrencyModel.swift
//  CurrencyConverter
//
//  Created by Arjun Gopakumar on 21/10/24.
//

import Foundation

    struct CurrencyConversionList: Codable {
        let success: Bool
        let base: String
        let date: String
        let rates: [String: Double]
    }
    
    struct CurrencyList : Codable{
        let name : String
        let code : String
        let flag : String
        let country : String
        let countryCode : String
        
        enum CodingKeys : String, CodingKey{
            case name
            case code
            case flag
            case country
            case countryCode
        }
        
        init(from decoder:Decoder) throws{
            let values = try decoder.container(keyedBy: CodingKeys.self)
            name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
            code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
            flag = try values.decodeIfPresent(String.self, forKey: .flag) ?? ""
            country = try values.decodeIfPresent(String.self, forKey: .country) ?? ""
            countryCode = try values.decodeIfPresent(String.self, forKey: .countryCode) ?? ""
          
        }
    }


