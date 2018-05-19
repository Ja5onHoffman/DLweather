//
//  ViewController.swift
//  DLweather
//
//  Created by Jason Hoffman on 5/19/18.
//  Copyright © 2018 Jason Hoffman. All rights reserved.
//

import UIKit
import CoreLocation

class GetWeatherVC: UIViewController {

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationlabel: UILabel!
    @IBOutlet weak var weatherButton: UIButton!
    @IBOutlet weak var tempSpinner: UIActivityIndicatorView!
    @IBOutlet weak var locationSpinner: UIActivityIndicatorView!
    
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest // battery expensive
        
        tempSpinner.isHidden = true
        locationSpinner.isHidden = true
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            // using 'always' here for simplicity
            locationManager?.requestAlwaysAuthorization()
        }
        
    }
    
    @IBAction func getWeatherButtonPressed(_ sender: Any) {
        locationManager?.requestLocation()
        toggleLocLabels()
        toggleTempLables()
    }

    func toggleLocLabels() {
        locationlabel.isHidden = !locationlabel.isHidden
        locationSpinner.isHidden = !locationSpinner.isHidden
    }

    func toggleTempLables() {
        tempLabel.isHidden = !tempLabel.isHidden
        tempSpinner.isHidden = !tempSpinner.isHidden
    }
    
    func getWeatherFor(location: String) {
        var baseUrl = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        let zipItem = URLQueryItem(name: "zip", value: "\(location)") // will have to do something with location here
        let keyItem = URLQueryItem(name: "APPID", value: "6a6522573406cfd06716284a258833e1")
        baseUrl?.queryItems = [zipItem, keyItem]
        guard let url = baseUrl?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let urlSessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfig)
        let task = urlSession.dataTask(with: request) { (data, res, err) in
            // async on main thread
            if let error = err {
                print(error)
            } else if let json = data {
                DispatchQueue.main.async {
                    do {
                        let response = try JSONSerialization.jsonObject(with: json, options: [])
                        // yes, ugly
                        if let dict = response as? [String: Any] {
                            if let main = dict["main"] as? [String: Any] {
                                if let temp = main["temp"] as? Double {
                                    let tempK = Measurement(value: temp, unit: UnitTemperature.kelvin)
                                    let tempF = tempK.converted(to: .fahrenheit)
                                    self.tempLabel.text = "\(round(tempF.value))"
                                }
                                self.toggleTempLables()
                            }
                        }
                    } catch {
                        print("error creating JSON")
                    }
                }
            }
        }
        
        task.resume()
    }
}

extension GetWeatherVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geoCoder = CLGeocoder()
        if let loc = locations.last {
            geoCoder.reverseGeocodeLocation(loc) { (placemark, error) in
                if let pl = placemark {
                    guard let zip = pl[0].postalCode else { print("no zip"); return }
                    self.getWeatherFor(location: "\(zip)")
                    self.locationlabel.text = "\(zip)"
                    self.toggleLocLabels()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location services failed")
    }
}
