//
//  ViewController.swift
//  fishProject
//
//  Created by 강대훈 on 2024/04/04.
//

import UIKit
import NMapsMap
import CoreLocation

// 메인화면 ViewController
class ViewController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var zoomControlView : NMFZoomControlView!
    
    let coastDataManager = CoastDataManager()
    let weatherDataManager = WeatherDataManager()
    var coastList : [Coast] = []
    var weatherList : [Weather] = []
    var locationManger = CLLocationManager()
    
    var myLat : Int?
    var myLon : Int?
    var tempCoastData : Coast?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let naverMapView = NMFNaverMapView(frame: view.frame)
        subView.addSubview(naverMapView)
        
        setMarkerData(naverMapView)
        setCoreLocation()
    }
    
    // 날씨 정보 데이터 얻기
    func setCoreLocation() {
        locationManger.delegate = self
        // 거리 정확도 설정
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        // 사용자에게 허용 받기 alert 띄우기
        locationManger.requestWhenInUseAuthorization()
  
        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
        
        DispatchQueue.global().async { [self] in // 현재 위치 lat, lon 받기
            if CLLocationManager.locationServicesEnabled() {
                locationManger.startUpdatingLocation() //위치 정보 받아오기 시작
                guard let lat = locationManger.location?.coordinate.latitude else { return }
                guard let lon = locationManger.location?.coordinate.longitude else { return }
                (myLat, myLon) = (Int(lat), Int(lon))
                
                guard let myLat = myLat else { return }
                guard let myLon = myLon else { return }
                
                let (current_Date, current_Time) = weatherDataManager.getCurrentTime()
                // 현재 시간을 Date 객체로 받아서 파싱을 통해서 어떻게 파라미터를 넘겨야 할지 고민해봐야 할 거 같음.
                weatherDataManager.fetchMovie(currentDate: current_Date, currentTime: current_Time, cur_x: String(myLat), cur_y: String(abs(myLon))) { weathers in
                    guard let weathers = weathers else {
                        print("데이터 전달 실패")
                        return
                    }
                    
                    self.weatherList = weathers
                    
                    var cnt = 0
                    for weather in self.weatherList {
                        cnt += 1
                        print(weather.predictDate, weather.category, weather.categoryValue)
                        if (cnt % 4 == 0) { print("--------------------------------------------") }
                    }
                }
            }
            else {
                print("위치 서비스 Off 상태")
            }
        }
    }
    
    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // DetailVC에 CoastData 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let detailVC = segue.destination as! DetailViewController
            
            detailVC.tempCoastData = self.tempCoastData
        }
    }
    
    // 마커 표시, 마커 누르면 데이터 및 화면 이동
    func setMarkerData(_ naverMapView : NMFNaverMapView) {
        
        coastList = coastDataManager.getCoastData()
        naverMapView.showLocationButton = true
        naverMapView.mapView.zoomLevel = 5
        
        for coast in coastList {
            guard let lat = Double(coast.obsLat) else { return }
            guard let lon = Double(coast.obsLon) else { return }
            
            let marker : NMFMarker = {
                let m = NMFMarker()
                m.position = NMGLatLng(lat: lat, lng: lon)
                m.width = 30
                m.height = 40
                m.captionText = coast.obsPostName
                m.mapView = naverMapView.mapView
                m.userInfo = ["tag" : coast.obsPostName]
                return m
            }()

            marker.touchHandler = { (overlay : NMFOverlay) -> Bool in // 마커 터치 핸들러 (이를 통해서 다양한 구현이 가능함.)
                guard let tappedMarkerName = overlay.userInfo["tag"] else { return false }
                
                guard let tappedMarkerName = tappedMarkerName as? String else { return false }
                
                for coast in self.coastList {
                    if (coast.obsPostName == tappedMarkerName) {
                        self.tempCoastData = coast
                        
                        // 9개의 정보 뿌림.
                        print("------------- \(coast.obsPostName) ------------")
                        print("tideLevel : ", coast.tideLevel)
                        print("Salinity : ", coast.salinity)
                        print("tideLevel : ", coast.tideLevel)
                        print("airTemp : ", coast.airTemp)
                        print("airPress : ", coast.airPress)
                        print("waterTemp : " , coast.waterTemp)
                        print("windDir : " , coast.windDir)
                        print("windGust : ", coast.windGust)
                        print("windSpeed : " , coast.windSpeed)
                        print("--------------------------------------")
                        break
                    }
                }
                
                self.performSegue(withIdentifier: "toDetailVC", sender: self)
                
                
                return true
            }
        }
    }
}


