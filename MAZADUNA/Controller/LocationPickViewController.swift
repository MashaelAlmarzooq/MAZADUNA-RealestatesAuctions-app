//
//  LocationPickViewController.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 24/09/21.
//

import UIKit
import MapKit
import CoreLocation

class LocationPickViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var post: Post!
    var locationManager = CLLocationManager()
    var fromPost: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLocationManager()
        // Do any additional setup after loading the view.
        if self.fromPost == false {
            if let coordinates = UserDefaults.standard.value(forKey: "LastPostLocation") as? Array<Double> {
                self.post.lat = coordinates.first ?? 0
                self.post.long = coordinates.last ?? 0
                self.updateLocationOnMap(to: CLLocation(latitude: coordinates.first ?? 0.0, longitude: coordinates.last ?? 0.0))
            }
            let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
            mapView.addGestureRecognizer(longTapGesture)
        } else {
            self.updateLocationOnMap(to: CLLocation(latitude: self.post.lat, longitude: self.post.long))
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureLocationManager() {
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    @objc func longTap(sender: UIGestureRecognizer) {
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            UserDefaults.standard.setValue([locationOnMap.latitude, locationOnMap.longitude], forKey: "LastPostLocation")
            self.updateLocationOnMap(to: CLLocation(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude))
            self.post.lat = locationOnMap.latitude
            self.post.long = locationOnMap.longitude
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func updateLocationOnMap(to location: CLLocation) {
        if self.fromPost == false {
            location.lookUpPlaceMark { (name) in
                self.post.location = name?.locality ?? "N/A"
                self.post.nigbh = name?.subLocality ?? "N/A"
            }
        }
        
        let point = MKPointAnnotation()
        point.title = title
        point.coordinate = location.coordinate
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(point)

        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(viewRegion, animated: true)
    }
}

extension LocationPickViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            if let coordinates = UserDefaults.standard.value(forKey: "LastPostLocation") as? CLLocationCoordinate2D {
                
            } else {
                self.setCurrentLocation()
            }
        }
    }
    
    func setCurrentLocation() {
        guard let currentLocation = locationManager.location, self.fromPost == false
            else { return }
        UserDefaults.standard.setValue([currentLocation.coordinate.latitude, currentLocation.coordinate.longitude], forKey: "LastPostLocation")
        self.post.lat = currentLocation.coordinate.latitude
        self.post.long = currentLocation.coordinate.longitude
        self.updateLocationOnMap(to: currentLocation)
    }
}

extension CLLocation {
    
    func lookUpPlaceMark(_ handler: @escaping (CLPlacemark?) -> Void) {
        
        let geocoder = CLGeocoder()
            
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                print("مشاعل")
                print(firstLocation?.locality)
                print(firstLocation?.subLocality)
                handler(firstLocation)
            }
            else {
                // An error occurred during geocoding.
                handler(nil)
            }
        }
    }
}
