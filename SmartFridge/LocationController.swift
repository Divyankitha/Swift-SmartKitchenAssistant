//
//  LocationController.swift
//  SmartFridge
//
//  Created by sindhya on 12/1/17.
//  Copyright © 2017 SJSU. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var groceryPlaces = Array<GroceryPlaces>()
    var clGeocoder = CLGeocoder()
    var userPinView: MKAnnotationView!
    
    fileprivate var isCurrentLocation: Bool = false
    
    var locationManager = CLLocationManager()
    fileprivate var annotation: MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.mapType = .standard
        
        if (CLLocationManager.locationServicesEnabled()) {
            //if locationManager == nil {
            locationManager = CLLocationManager()
            //}
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            isCurrentLocation = true
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
        getNearbyGroceryPlaces();
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isCurrentLocation {
            return
        }
        
        isCurrentLocation = false
        
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = ""
        mapView.addAnnotation(pointAnnotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Location manager failed with error = \(error)")
    }
    
    func displayPlaces(places: Array<GroceryPlaces>) {
        var i = 1
        var coordinates: CLLocationCoordinate2D?
        var placemark: CLPlacemark?
        var annotation: Annotation?
        var stations:Array = [Annotation]()
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        for address in places {
            clGeocoder = CLGeocoder() //new geocoder
            let lat = String(format:"%.2f", address.latitude!)
            let long = String(format:"%.2f", address.longitude!)
            
            let location = CLLocation(latitude : Double(lat)!,longitude: Double(long)!)
            clGeocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            //clGeocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil)  {
                    print("Error", error!)
                }
                placemark = placemarks?.first
                if placemark != nil {
                    coordinates = placemark!.location!.coordinate
                    points.append(coordinates!)
                    print("locations = \(coordinates!.latitude) \(coordinates!.longitude)")
                    annotation = Annotation(latitude: coordinates!.latitude, longitude: coordinates!.longitude, address: address.name!, subTitle: address.openStatus!)
                    stations.append(annotation!)
                    print(stations.count)
                    print(i)
                    if (i == self.groceryPlaces.count) {
                        print("Print map...")
                        self.mapView.addAnnotations(stations)
                    }
                    i+=1
                }
            })
        }
    }
    
    func getNearbyGroceryPlaces(){
        let placesURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.391,-121.982&radius=2000&type=grocery_or_supermarket&key=AIzaSyCQ7nzuqrkbFNf15vueqVljJixWo56jzRw"
        
        
        var request = URLRequest(url: URL(string: placesURL)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in print( response ?? "Error connecting to Rest API - GET Google places")
            if error != nil
            {
                print("Failed to connect to Google places API")
                print(error!)
            }
            else
            {
                print("Data Obtained")
                self.parseJSON(data!)
                
                DispatchQueue.main.async
                {
                    self.displayPlaces(places: self.groceryPlaces)
                }
                
            }
            
            if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode == 200
                {
                    print("Retrived grocery list")
                    
                }
                else
                {
                    print(httpResponse.statusCode)
                    print("Failed to retrive grocery list")
                }
            }
            
        })
        
        task.resume()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //if annotation is MKUserLocation {
        if annotation is MKUserLocation {
            return nil
        }
        /*let pin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
         pin.image = self.imageWithImage(image: UIImage(named: "marker")!, scaledToSize: CGSize(width: 30.0, height: 30.0))
         userPinView = pin
         return pin*/
        
        let annotationIdentifier = "Identifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            
            annotationView.canShowCallout = true
            annotationView.image = self.imageWithImage(image: UIImage(named: "marker")!, scaledToSize: CGSize(width: 30.0, height: 30.0))
        }
        
        return annotationView
        
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        //image.draw(in: CGRect(0, 0, newSize.width, newSize.height))
        image.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: newSize.width, height: newSize.height))  )
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func parseJSON(_ data:Data){
        groceryPlaces = Array<GroceryPlaces>()
        
        //let groceryPlacesItem = GroceryPlaces()
        
        do {
            
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let results = json["results"] as? [[String: Any]] {
                for res in results {
                    
                    let groceryItem = GroceryPlaces()
                    
                    let googleGeo = res["geometry"] as! NSDictionary
                    let placeName = res["name"] as! String
                    let googleLoc = googleGeo["location"] as! NSDictionary
                    let latitude = googleLoc["lat"] as! Float
                    let longitude = googleLoc["lng"] as! Float
                    
                    let open_hours = res["opening_hours"] as! NSDictionary
                    let open_now = open_hours["open_now"] as! Bool
                    
                    groceryItem.name = placeName
                    groceryItem.latitude = latitude
                    groceryItem.longitude = longitude
                    if open_now == true{
                        groceryItem.openStatus = "Open"}
                    else{
                        groceryItem.openStatus = "Not Open"}
                    
                    self.groceryPlaces.append(groceryItem)
                
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
        }
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    class Annotation: NSObject, MKAnnotation {
        var title: String?
        var subtitle: String?
        var lat: Double
        var long:Double
        
        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        init(latitude: Double, longitude: Double, address: String, subTitle: String) {
            self.lat = latitude
            self.long = longitude
            self.title = address
            self.subtitle = subTitle
        }
    }
    
    

}
