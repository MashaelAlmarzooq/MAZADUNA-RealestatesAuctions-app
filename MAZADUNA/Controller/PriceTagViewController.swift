//
//  PriceTagViewController.swift
//  MAZADUNA
//
//  Created by Meshael Hamad on 02/11/21.
//

import UIKit
import MapKit
import CoreLocation

class PriceTagViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.configureLocationManager()
        self.addPostsToMap(AllPosts.shared.posts)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("PostReload"), object: nil, queue: .main) { (notification) in
            if let posts = notification.object as? [Post] {
                self.addPostsToMap(posts)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("PostReload"), object: nil)
    }
    
    func configureLocationManager() {
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    self.setCurrentLocation()
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
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
        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    func addPostsToMap(_ posts: [Post]) {
        posts.forEach { (post) in
            self.addPriceTag(post)
        }
    }
    
    func addPriceTag(_ post: Post) {
        let point = MKPointAnnotation()
        point.title = post.startPrice
        point.subtitle = post.postID
        point.coordinate = CLLocationCoordinate2D(latitude: post.lat, longitude: post.long)
        self.mapView.addAnnotation(point)
    }
}

extension PriceTagViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            self.setCurrentLocation()
        }
    }
    
    func setCurrentLocation() {
        guard let currentLocation = locationManager.location
            else { return }
        self.updateLocationOnMap(to: currentLocation)
    }
}

extension PriceTagViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let view = Bundle.main.loadNibNamed("priceTagView", owner: self, options: nil)?.first as? priceTagView else { return nil }
        if let post = AllPosts.shared.posts.first(where: {$0.postID == annotation.subtitle}) {
                   view.priceLabel.text = post.price + " "+NSLocalizedString("realEstateCurrency", comment: "")
                   view.post = post
                   view.tapButton.addTarget(self, action: #selector(self.priceTagTapped(_:)), for: .touchUpInside)
            view.priceLabel.sizeToFit()
        }
        
        return view
    }
    
    @IBAction func priceTagTapped(_ sender: UIButton) {
        guard let annotation = sender.superview?.superview as? priceTagView else { return }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewInfo") as? ViewInfo else { return }
        vc.post = annotation.post
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
