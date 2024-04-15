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
    
    class ItemKey: NSObject, NMCClusteringKey { // 클러스터링에 필요한 필수 클래스
        let identifier: Int
        let position: NMGLatLng

        init(identifier: Int, position: NMGLatLng) {
            self.identifier = identifier
            self.position = position
        }

        static func markerKey(withIdentifier identifier: Int, position: NMGLatLng) -> ItemKey {
            return ItemKey(identifier: identifier, position: position)
        }

        override func isEqual(_ o: Any?) -> Bool {
            guard let o = o as? ItemKey else {
                return false
            }
            if self === o {
                return true
            }

            return o.identifier == self.identifier
        }

        override var hash: Int {
            return self.identifier
        }

        func copy(with zone: NSZone? = nil) -> Any {
            return ItemKey(identifier: self.identifier, position: self.position)
        }
    }
    
    let coastDataManager = CoastDataManager()
    var coastList : [Coast] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coastList = coastDataManager.getCoastData()
        
        sleep(10)
        
        let mapView = NMFMapView(frame: view.frame)
        mapView.zoomLevel = 1
        view.addSubview(mapView)
        let builder = NMCBuilder<ItemKey>()
        let clusterer = builder.build()
        
        var cnt = 1
        
        for coastData in coastList {
            guard let obsLat = Double(coastData.obsLat) else { return }
            guard let obsLon = Double(coastData.obsLon) else { return }
            clusterer.add(ItemKey(identifier: cnt, position: NMGLatLng(lat: obsLat, lng: obsLon)), nil)
            print(obsLat, obsLon)
            cnt += 1
        }
        
        clusterer.mapView = mapView
    }
}



