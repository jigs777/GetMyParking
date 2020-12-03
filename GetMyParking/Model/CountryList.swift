//
//  CountryList.swift
//  GetMyParking
//
//  Created by Piyu on 22/11/20.
//

import Foundation

struct RootRuesult : Decodable {
    let alpha2Code : String?
    let alpha3Code : String?
    let altSpellings : [String]?
    let area : Double?
    let borders : [String]?
    let callingCodes : [String]?
    let capital : String?
    let cioc : String?
    let currencies : [RootCurrency]?
    let demonym : String?
    let flag : String?
    let gini : Double?
    let languages : [RootLanguage]?
    let latlng : [Double]?
    let name : String?
    let nativeName : String?
    let numericCode : String?
    let population : Int?
    let region : String?
    let regionalBlocs : [RootRegionalBloc]?
    let subregion : String?
    let timezones : [String]?
    let topLevelDomain : [String]?
    let translations : RootTranslation?

}
struct RootCurrency : Decodable {
    let code : String?
    let name : String?
    let symbol : String?
}
struct RootLanguage : Decodable {
    let iso639_1 : String?
    let iso639_2 : String?
    let symbol : String?
}
struct RootRegionalBloc : Decodable {
    let acronym : String?
    let name : String?
    let otherAcronyms : [String]?
    let otherNames : [String]?
}
struct RootTranslation : Decodable {
    let br : String?
    let de : String?
    let es : String?
    let fa : String?
    let fr : String?
    let hr : String?
    let it : String?
    let ja : String?
    let nl : String?
    let pt : String?
}
