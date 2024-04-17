//
//  ViewController.swift
//  fishProject
//
//  Created by 강대훈 on 2024/04/04.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    
    @IBOutlet weak var zoomControlView : NMFZoomControlView!
    
    let coastDataManager = CoastDataManager()
    var coastList : [Coast] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var mapView = NMFMapView(frame: view.frame)
        
        mapInfo(mapView)
        getMarkerData(mapView)
    }
    
    func mapInfo(_ mapView : NMFMapView) {
        
        mapView.zoomLevel = 5
        view.addSubview(mapView)
    }
    
    func getMarkerData(_ mapView : NMFMapView) {
        
        coastList = coastDataManager.getCoastData()
        
        for coast in coastList {
            guard let lat = Double(coast.obsLat) else { return }
            guard let lon = Double(coast.obsLon) else { return }

            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: lat, lng: lon)
            marker.mapView = mapView

            marker.touchHandler = { (overlay : NMFOverlay) -> Bool in // 마커 터치 핸들러 (이를 통해서 다양한 구현이 가능함.)
                print(overlay.overlayID)
                return true
            }
        }
    }
}



