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
    
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest // battery expensive
        
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            // usint 'always' here for simplicity
            locationManager?.requestAlwaysAuthorization()
        }
        
    }
    
    @IBAction func getWeatherButtonPressed(_ sender: Any) {
        locationManager?.requestLocation()
    }
    
//    func getLocation() {
//        locationManager?.requestLocation()
//    }

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
                    } catch {
                        print("err")
                    }
                }
            } else {
                print("not working")
            }
        }
        
        task.resume()
    }
    
//    func dummu() {
//        var urlComponents = URLComponents()
//        urlComponents.scheme = "https"
//        urlComponents.host = "jsonplaceholder.typicode.com"
//        urlComponents.path = "/posts"
//        let userIdItem = URLQueryItem(name: "userId", value: "\(userId)")
//        urlComponents.queryItems = [userIdItem]
//        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//        let task = session.dataTask(with: request) { (responseData, response, responseError) in
//            DispatchQueue.main.async {
//                if let error = responseError {
//                    completion?(.failure(error))
//                } else if let jsonData = responseData {
//                    // Now we have jsonData, Data representation of the JSON returned to us
//                    // from our URLRequest...
//
//                    // Create an instance of JSONDecoder to decode the JSON data to our
//                    // Codable struct
//                    let decoder = JSONDecoder()
//
//                    do {
//                        // We would use Post.self for JSON representing a single Post
//                        // object, and [Post].self for JSON representing an array of
//                        // Post objects
//                        let posts = try decoder.decode([Post].self, from: jsonData)
//                        completion?(.success(posts))
//                    } catch {
//                        completion?(.failure(error))
//                    }
//                } else {
//                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
//                    completion?(.failure(error))
//                }
//            }
//        }
//
//        task.resume()
//    }
}

extension GetWeatherVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geoCoder = CLGeocoder()
        if let loc = locations.last {
            geoCoder.reverseGeocodeLocation(loc) { (placemark, error) in
                if let pl = placemark {
                    print(pl[0])
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location services failed")
    }
}
