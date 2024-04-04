//
//  ViewController.swift
//  fishProject
//
//  Created by 강대훈 on 2024/04/04.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
        let mapView = NMFMapView(frame : view.frame)
        marker.mapView = mapView
        view.addSubview(mapView)
    }


}

