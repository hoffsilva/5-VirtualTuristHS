//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 02/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import MapKit



class PhotoAlbumCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    var photoPersistence = PhotoPersistence()
    
    var flickrFinder = FlickrFinder()
    
    var selectedPin: CLLocationCoordinate2D!
    var currentPin: Pin?
    var pinPersistence = PinPersistence()
    
    var photos = [Photo]()
    
    var numberOfPage = 1
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView_SelectedPin: MKMapView!
    @IBOutlet weak var button_newCollection: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawPinOnMap()
        mapView_SelectedPin.delegate = self
        
        //Set to current pin
        photoPersistence.coordinates.latitude = selectedPin.latitude
        photoPersistence.coordinates.longitude = selectedPin.longitude
        // Get the photo's
        photos = photoPersistence.buscarPhotos()
        //print("# of photos: \(photos.count)" )
        button_newCollection.enabled = false
        button_newCollection.backgroundColor = UIColor.grayColor()
        button_newCollection.alpha = 0.5
        collectionView?.scrollIndicatorInsets.bottom
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
       
        
        if photos.count == 0{
            searchImagesWhenPhotosIsEmpty()
        }
        
        let lpgr = UILongPressGestureRecognizer(target: self, action:"handleLongPress:")
        lpgr.minimumPressDuration = 1
        lpgr.delaysTouchesBegan = false
        self.collectionView.addGestureRecognizer(lpgr)
        getActualImages()
    }
    
    func searchImagesWhenPhotosIsEmpty(){
        let pin = pinPersistence.buscarSelectedPin(selectedPin)
        currentPin = pin[0]
        flickrFinder.searchFlickByCoondinate(selectedPin.latitude, longitude: selectedPin.longitude, numberOfPage: "", currentPin: currentPin!, onCompletion: { () -> Void in
            self.photos = self.photoPersistence.buscarPhotos()
            self.getActualImages()
            self.collectionView.reloadData()
            
        })

    }
    
    func getActualImages() {
        for photo in self.photos{
            // Check if we a/ready have the jpg files
            if photo.jpgName == nil {
                //print("getting jpg from flickr")
                // No we don't have it: so go get it from flickr
                if let checkedUrl = NSURL(string: photo.url!) {
                    self.getDataFromUrl(checkedUrl) { (data, response, error)  in
                        //self.photosOfDocuments.append(self.photoFileURL(response?.suggestedFilename ?? ""))
                        //print(self.photosOfDocuments)
                        if error == nil {
                            
                            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                
                                photo.jpgName = response?.suggestedFilename
                                
                                let imageToSave = UIImage(data: data!)
                                let data = UIImageJPEGRepresentation(imageToSave!, 1)
                                data!.writeToFile(self.photoFileURL(response?.suggestedFilename ?? "").path!, atomically: true)
                                
                                
                                CoreDataStackManager.sharedInstance().saveContext()
                            }
                        } else {
                            print("error getting image from URL")
                        }
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.collectionView.reloadData()
                        }
                    }
                }
            } else {
                // for debugging
                //print("we have a jpg file")
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        CoreDataStackManager.sharedInstance().saveContext()
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
        
        pinView!.image = UIImage(named:"pin")!
        pinView!.centerOffset = CGPoint(x: -1, y: -12)
        
        return pinView
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = "Cell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageFromFlickrCollectionViewCell
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        
        cell.downloadingImage.startAnimating()
        cell.imageView.contentMode = .ScaleAspectFill
        
        // If we have an image we can show it; else you should use some default placeholder image
        if self.photos[indexPath.row].jpgName != nil {
            //print(self.photos[indexPath.row].jpgName!)
            let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/" + self.photos[indexPath.row].jpgName!
            let image = UIImage(contentsOfFile: path)
            let imageView = UIImageView(image: image)
            cell.backgroundView = imageView
            cell.downloadingImage.stopAnimating()
            
        } else {
            // Optional: Make a default image and use that for the cell (this should take care of the layout errors in the console
        }
        
        self.button_newCollection.alpha = 1
        self.button_newCollection.enabled = true
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath)
        
        return view
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if photos.count > 0{
            return CGSizeZero
        }else{
            
            return CGSize(width: self.view.frame.size.width, height: 50)
            
        }
    }
    
    
    @IBAction func action_newCollection(sender: AnyObject) {
        numberOfPage = numberOfPage + 1
        
        if photos.count > 0 {
            currentPin = nil
            for phot in photos{
                if currentPin == nil {
                    currentPin = phot.place
                }
                //1) delete jpg file from folder
                let fileToDelete = phot.jpgName
                if fileToDelete != nil{
                    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/" + fileToDelete!
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(path)
                    } catch _ {
                        print("errror deleting image")
                    }
                }
                phot.jpgName = nil
                //2) delete photo from core data
                photoPersistence.sharedContext.deleteObject(phot)
            }
            CoreDataStackManager.sharedInstance().saveContext()
            
            
            self.collectionView?.reloadData()
            print("about to get new images")
            
            
            flickrFinder.searchFlickByCoondinate(selectedPin.latitude, longitude: selectedPin.longitude, numberOfPage: "\(numberOfPage)", currentPin: currentPin!) { () -> Void in
                
                print("found some new photo's")
                self.photos.removeAll()
                self.photos = self.photoPersistence.buscarPhotos()
                self.getActualImages()
            }
        }else{
            searchImagesWhenPhotosIsEmpty()
        }
    }
    
    func photoFileURL(nomeDaFoto: String) ->  NSURL {
        let filename = nomeDaFoto
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        
        return fileURL
    }
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    
    func drawPinOnMap(){
        self.mapView_SelectedPin.removeAnnotations(self.mapView_SelectedPin.annotations)
        var annotations = [MKPointAnnotation]()
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = self.selectedPin.latitude
        annotation.coordinate.longitude = self.selectedPin.longitude
        
        annotations.append(annotation)
        
        var region = MKCoordinateRegion()
        region.center = annotation.coordinate
        self.mapView_SelectedPin.setRegion(region, animated: true)
        self.mapView_SelectedPin.camera.altitude = 100000
        
        self.mapView_SelectedPin.addAnnotations(annotations)
        self.mapView_SelectedPin.setCenterCoordinate(self.mapView_SelectedPin.region.center, animated: true)
        
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Began {
            return
        }
        
        let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gestureReconizer.locationInView(self.collectionView))
        var indexPathRow = selectedIndexPath?.row
        let fileToDelete = photos[indexPathRow!].jpgName
        if fileToDelete != nil{
            let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/" + fileToDelete!
            print("File to delete: \(path)")
            do {
                print("Trying delete file: \(path)")
                try NSFileManager.defaultManager().removeItemAtPath(path)
                print("File \(path) deleted with success!")
            } catch _ {
                print("errror deleting image")
            }
        }
        photos[indexPathRow!].jpgName = nil
        //2) delete photo from core data
        print("The photo \(photos[indexPathRow!]) will be deleted from core data!")
        photoPersistence.sharedContext.deleteObject(photos[indexPathRow!])
        
        photos.removeAtIndex(indexPathRow!)
        collectionView.reloadData()
        return
    }
    
    func actionDetailPhoto(){
        self.performSegueWithIdentifier("detailPhoto", sender: view)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailPhoto"{
            let indexPaths = collectionView.indexPathsForSelectedItems()
            let indexPath = indexPaths![0] as! NSIndexPath
            let detailPhoto : DetailPhotoViewController = segue.destinationViewController as! DetailPhotoViewController
            detailPhoto.photo = photos[indexPath.row]
            print(photos[indexPath.row])
        }
    }
    
}
