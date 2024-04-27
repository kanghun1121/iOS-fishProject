//
//  FishingViewController.swift
//  fishProject
//
//  Created by 강대훈 on 2024/04/22.
//

import UIKit
import NMapsMap
import CoreLocation
import Alamofire
import SwiftyJSON

// 낚시터 VC
class FishingViewController: UIViewController, CLLocationManagerDelegate {
    
    var fishingList : [Fishing] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let naverMapView = NMFNaverMapView(frame: view.frame)
        view.addSubview(naverMapView)
        self.loadFishingDataFromCSV(naverMapView)
        
        
        // Do any additional setup after loading the view.
    }
    
    func parseCSVAt(url: URL, _ naverMapView : NMFNaverMapView) {
            do {
                // url을 받은 data
                let data = try Data(contentsOf: url)
                // 해당 data를 encoding 합니다.
                let dataEncoded = String(data: data, encoding: .utf8)
                // ,로 구분해 만든 리스트
                if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                    for data in dataArr {
                        if (data[0] == "번호") { continue } // header 제거
                        
                        let idNumber = Int(data[0]) ?? 0
                        let fishingPlaceName = data[1]
                        let fishingType = data[2]
                        let fishingAddress = data[3]
                        let lat : Double = Double(data[4]) ?? 0
                        let lon : Double = Double(data[5]) ?? 0
                        let fishingFacilities = data[6]
                        
                        let tempFishingData : Fishing = Fishing(idNumber: idNumber, fishingPlaceName: fishingPlaceName, fishingType: fishingType, fishingAddress: fishingAddress, lat: lat, lon: lon, fishingFacilities: fishingFacilities)
                        
                        fishingList.append(tempFishingData)
                    }
                }
                
                for fishingData in fishingList {
                    let marker : NMFMarker = {
                        let m = NMFMarker()
                        m.position = NMGLatLng(lat: fishingData.lat, lng: fishingData.lon)
                        m.width = 30
                        m.height = 40
                        m.captionText = fishingData.fishingPlaceName
                        m.subCaptionText = fishingData.fishingAddress
                        m.subCaptionColor = .blue
                        m.mapView = naverMapView.mapView
                        m.isHideCollidedSymbols = true
                        
                        let infoWindow = NMFInfoWindow()
                        let dataSource = NMFInfoWindowDefaultTextSource.data()
                        
                        dataSource.title = "Hi\n" + "Hi"
                        infoWindow.dataSource = dataSource
                        
                        m.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
                            if let marker = overlay as? NMFMarker {
                                if marker.infoWindow == nil {
                                    // 현재 마커에 정보 창이 열려있지 않을 경우 엶
                                    infoWindow.open(with: marker)
                                } else {
                                    // 이미 현재 마커에 정보 창이 열려있을 경우 닫음
                                    infoWindow.close()
                                }
                            }
                            return true
                        }
                        
                        return m
                    }()
                }
                
                
            } catch {
                print("Error reading CSV file")
            }
        }
    
    func loadFishingDataFromCSV(_ naverMapView : NMFNaverMapView) {
            // bundle에 있는 경로 > csv 파일 경로
            let path = Bundle.main.path(forResource: "fishingData", ofType: "csv")!
            parseCSVAt(url: URL(fileURLWithPath: path), naverMapView)
        }
}
