//
//  ViewController.swift
//  RandomPeople
//
//  Created by Mike Spears on 2021-02-07.
//

import UIKit
import MapKit

class User : NSObject, Codable,  MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude)!, longitude: CLLocationDegrees(longitude)!)
    }
    var title: String? {
        return email
    }
    
    
    var email: String!
    var latitude: String!
    var longitude: String!
    

}
class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    var mapView: MKMapView!
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView = MKMapView(frame: self.view.bounds)
        self.mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(self.mapView)
  
        self.mapView.delegate = self
        self.mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.mapTapAction(sender:)))
        
        self.mapView.addGestureRecognizer(tapGesture)
        
        
        
        self.updateUsersFromServer()
        
        // Do any additional setup after loading the view.
    }
    
    func updateUsersFromServer() {
        let url = URL(string:"https://iccit-media-cloud.glitch.me/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                debugPrint(error?.localizedDescription ?? "no data")
                return
            }
            self.users = try! JSONDecoder().decode([User].self, from: data)
            DispatchQueue.main.async {
                self.addPinsToMap()
            }
        }.resume()
    }

    func addPinsToMap() {
        self.users.forEach { (user) in
            self.mapView.addAnnotation(user)
        }
        self.mapView.showAnnotations(self.users, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation)
        annotation.canShowCallout = true
        (annotation as! MKPinAnnotationView).pinTintColor = UIColor(named:"COLOR4")
        return annotation

    }
    
    @IBAction func mapTapAction(sender: UITapGestureRecognizer) {
        let pointInView = sender.location(in: self.mapView)
        let coordinates = self.mapView.convert(pointInView, toCoordinateFrom: self.mapView)
        
        let url = URL(string:"https://iccit-media-cloud.glitch.me/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "latitude=\(coordinates.latitude)&longitude=\(coordinates.longitude)&email=new.person@example.com"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                self.updateUsersFromServer()
            }
        }.resume()
    }

}

