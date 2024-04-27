//
//  FishingDataManager.swift
//  fishProject
//
//  Created by 강대훈 on 2024/04/27.
//

import Foundation

struct Fishing {
    var idNumber : Int
    var fishingPlaceName : String
    var fishingType : String
    var fishingAddress : String
    var lat : Double
    var lon : Double
    var fishingFacilities : String
    
    init(idNumber: Int, fishingPlaceName: String, fishingType: String, fishingAddress: String, lat: Double, lon: Double, fishingFacilities : String) {
        self.idNumber = idNumber
        self.fishingPlaceName = fishingPlaceName
        self.fishingType = fishingType
        self.fishingAddress = fishingAddress
        self.lat = lat
        self.lon = lon
        self.fishingFacilities = fishingFacilities
    }
}
