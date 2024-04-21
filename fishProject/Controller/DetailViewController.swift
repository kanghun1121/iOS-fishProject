//
//  DetailViewController.swift
//  fishProject
//
//  Created by 강대훈 on 2024/04/20.
//

import UIKit

class DetailViewController: UIViewController {

    var tempCoastData : Coast?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetting()
        // Do any additional setup after loading the view.
    }
    
    func viewSetting() {
        guard let tempCoastData = tempCoastData else { return }
        dump(tempCoastData)
        
        // WeatherDataManager 사용해서 마커 위치 날씨 정보 가져오기
        
        // CoastData Label 사용해서 뿌려주기
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
