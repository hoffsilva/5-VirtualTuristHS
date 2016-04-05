//
//  FlickrFinder.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 04/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import UIKit
import MapKit


class FlickrFinder: NSObject {
    
    var dictionaryPhotos = [[String:AnyObject]]()
    var teste = [Photo]()
    var lati = ""
    var long = ""
    var pin : Pin!
    
    var coordinates = CLLocationCoordinate2D()
    
    var pinPersistence = PinPersistence()
    var photosPersistence = PhotoPersistence()
    
    let arrayImagens = []
    
    
    func searchFlickByCoondinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees, numberOfPage: String, currentPin: Pin, onCompletion: () -> Void) {
        print("search with coordinate")
        pin = currentPin
        Constants.PAGE = numberOfPage
        
        if Constants.PAGE != ""{
            coordinates.latitude = latitude
            coordinates.longitude = longitude
        }
        
        
        let methodArguments = [
            "method": Constants.METHOD_NAME,
            "api_key": Constants.API_KEY,
            "lat": String(latitude),
            "lon": String(longitude),
            "safe_search": Constants.SAFE_SEARCH,
            "extras": Constants.EXTRAS,
            "format": Constants.DATA_FORMAT,
            "per_page": Constants.per_page,
            "page" : Constants.PAGE,
            "nojsoncallback": Constants.NO_JSON_CALLBACK
        ]
        
        
        getImageFromFlickrBySearch(methodArguments,  onCompletion: onCompletion)
        
    }
    
    
    func getImageFromFlickrBySearch(methodArguments : [String : AnyObject], onCompletion: () -> Void) {
        //print("get  images by search")
        let session = NSURLSession.sharedSession()
        let urlString = Constants.BASE_URL + escapedParameters(methodArguments)
        
        //print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session .dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError{
                print("Nao foi possivel completar a requisicao!!! \(error)")
            }else{
                var parsingError : NSError? = nil
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                guard let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] else{
                    print("Nao foi possivel encontrar a chave photos no \(parsedResult)")
                    return
                }
                
                guard let perpage = photosDictionary["perpage"] as? Int else{
                    print("Nao foi possivel encontrar a chave total no \(photosDictionary["perpage"])")
                    
                    return
                }
                // print(perpage)
                
                if Int(perpage) == Int(Constants.per_page) {
                    
                    guard let photosArray = photosDictionary["photo"] as? [[String:AnyObject]] else{
                        print("Na foi possivel encontrar a chave photo no \(photosDictionary)")
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dictionaryPhotos.removeAll()
                        self.dictionaryPhotos = photosArray
                        self.photosPersistence.savePhotos(self.dictionaryPhotos, place: self.pin )
                        onCompletion()
                    })
                    
                }else{
                    print("Nenhuma foto foi encontrada com este parametro!!!")
                }
                
            }
            
        }
        
        task.resume()
        
    }
    
}




func escapedParameters(parameters: [String : AnyObject]) -> String {
    
    var urlVars = [String]()
    
    for (key, value) in parameters {
        
        /* Make sure that it is a string value */
        let stringValue = "\(value)"
        
        /* Escape it */
        let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /* Append it */
        urlVars += [key + "=" + "\(escapedValue!)"]
        
    }
    
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
}


