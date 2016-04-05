//
//  ViewController.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 02/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var lat = Double()
    var long = Double()
    
    var photoAlbum2 = PhotoAlbumCollectionViewController()
    
    var pinPersistence = PinPersistence()
    
    var selectedPin = CLLocationCoordinate2D()
    var currentPin: Pin!
    
    var lastPositionPersistence = LastPositionPersistence()
    
    var flickr = FlickrFinder()
    
    var pins = [Pin]()
    
    var lastPosition = [LastPosition]()
    
    var photoPersistence = PhotoPersistence()
    
    
    override func viewWillAppear(animated: Bool) {
        mapView.delegate = self
        getPinsAndLastPosition()
        activeLongPressInteraction()
        compareLastCordinatesWithCurrentCordinates()
        drawPinsOnMap()
        
    }
    
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView!.annotation = annotation
        }
        let btn_delete = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
        let btnImageDelete = UIImage(named: "trash")! as UIImage
        btn_delete.setImage(btnImageDelete, forState: .Normal)
        btn_delete.addTarget(self, action: "deletePin", forControlEvents: .TouchUpInside)
        
        let btn_photoAlbum = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
        let btnImagePhotoAlbum = UIImage(named: "grid")! as UIImage
        btn_photoAlbum.setImage(btnImagePhotoAlbum, forState: .Normal)
        btn_photoAlbum.addTarget(self, action: "photoAlbum", forControlEvents: .TouchUpInside)
        
        pinView!.canShowCallout = true
        pinView!.image = UIImage(named:"pin")!
        
        pinView!.rightCalloutAccessoryView = btn_photoAlbum
        pinView!.leftCalloutAccessoryView = btn_delete
        pinView!.centerOffset = CGPoint(x: -1, y: -12)
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        lastPositionPersistence.savePin(mapView.region.center, timeStamp: NSDate(), altitude: mapView.camera.altitude )
    }
    
    //MARK - Call PhotoAlbum
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "photoAlbum"{
            let photoAlbum: PhotoAlbumCollectionViewController = segue.destinationViewController as! PhotoAlbumCollectionViewController
            print(selectedPin)
            photoAlbum.selectedPin =  selectedPin
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        selectedPin = (view.annotation?.coordinate)!
    }
    
    func photoAlbum(){
        self.performSegueWithIdentifier("photoAlbum", sender: view)
    }
    
    func deletePin(){
        print("in deletePin")
        for pin in pins{
            
            if pin.longitude == selectedPin.longitude && pin.latitude == selectedPin.latitude{
                
                print ("removing annotation")
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pin.coordinate.latitude
                annotation.coordinate.longitude = pin.coordinate.longitude
                self.mapView.removeAnnotation(annotation)
                
                //@TODO Just before deleting the pin from coredata you should delete
                // all the jpg files for this pin from the document folder
                photoPersistence.coordinates.latitude = selectedPin.latitude
                photoPersistence.coordinates.longitude = selectedPin.longitude
                let photosOfPin = photoPersistence.buscarPhotos()
                if photosOfPin.count > 0{
                    for photo in photosOfPin {
                        
                        let fileToDelete = photo.jpgName
                        if fileToDelete != nil{
                            let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/" + fileToDelete!
                            do {
                                try NSFileManager.defaultManager().removeItemAtPath(path)
                            } catch _ {
                                print("error removing files from folder")
                            }
                        }
                    }
                }
                
                CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(pin)
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
        
        // Refresh the UI
        pins = pinPersistence.buscarPins()
        drawPinsOnMap()
        
    }
    
    //MARK - Draw pins on Map
    
    func drawPinsOnMap(){
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.reloadInputViews()
        var annotations = [MKPointAnnotation]()
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = "|"
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
        self.mapView.setCenterCoordinate(self.mapView.region.center, animated: true)
    }
    
    //MARK - Verifying if current cordinates to set last position on Map.
    
    func compareLastCordinatesWithCurrentCordinates(){
        if lastPosition.first?.latitude == nil{
            print(lastPosition.first?.latitude)
            var region = MKCoordinateRegion()
            region.center.latitude = Constants.defaultLatitude
            region.center.longitude = Constants.defaultLongitude
            mapView.setRegion(region, animated: true)
            mapView.camera.altitude = Constants.defaultCameraAltitude
            mapView.zoomEnabled = true
            
        }else{
            mapView.reloadInputViews()
            print(lastPosition.first?.coordinate)
            var position = CLLocationCoordinate2D()
            position.latitude = (lastPosition.first?.coordinate.latitude)!
            position.longitude = (lastPosition.first?.coordinate.longitude)!
            var region = MKCoordinateRegion()
            region.center.latitude = (lastPosition.first?.coordinate.latitude)!
            region.center.longitude = (lastPosition.first?.coordinate.longitude)!
            mapView.setRegion(region, animated: true)
            mapView.camera.altitude = Double((lastPosition.first?.altitude)!)
            mapView.zoomEnabled = true
        }
    }
    
    //MARK - Initialize the var that map view will use.
    
    func getPinsAndLastPosition(){
        pins = pinPersistence.buscarPins()
        lastPosition = lastPositionPersistence.buscarLastLocation()
    }
    
    //MARK - Turn on longpress action
    
    func activeLongPressInteraction() {
        let lpgr = UILongPressGestureRecognizer(target: self, action:"handleLongPress:")
        lpgr.minimumPressDuration = 1
        lpgr.delaysTouchesBegan = false
        self.mapView.addGestureRecognizer(lpgr)
    }
    
    //MARK - get position when longpress on map
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Began {
            return
        }
        let touchLocation = gestureReconizer.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation,toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        let newPin = pinPersistence.savePin(locationCoordinate)
        
        // now find some photo's
        flickr.searchFlickByCoondinate(locationCoordinate.latitude, longitude: locationCoordinate.longitude, numberOfPage: "", currentPin: newPin) { () -> Void in
            print("Completed in Travel!")
        }
        flickr.coordinates = locationCoordinate
        annotation.title = "|"
        self.mapView.addAnnotation(annotation)
        return
    }
    
}

