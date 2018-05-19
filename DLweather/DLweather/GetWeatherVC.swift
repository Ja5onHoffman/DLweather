//
//  ViewController.swift
//  DLweather
//
//  Created by Jason Hoffman on 5/19/18.
//  Copyright © 2018 Jason Hoffman. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationlabel: UILabel!
    @IBOutlet weak var weatherButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension ViewController: CLLocationManagerDelegate {
    
}
