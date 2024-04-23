//
//  FishingViewController.swift
//  fishProject
//
//  Created by 강대훈 on 2024/04/22.
//

import UIKit
import NMapsMap

// 낚시터 VC
class FishingViewController: UIViewController, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let naverMapView = NMFNaverMapView(frame: view.frame)
        view.addSubview(naverMapView)
        // Do any additional setup after loading the view.
        
        
        
        
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
