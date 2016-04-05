//
//  Pin.swift
//  Virtual Tourist - HoffSilva
//
//  Created by Hoff Henry Pereira da Silva on 04/03/16.
//  Copyright © 2016 Hoff Silva. All rights reserved.
//

import Foundation
import CoreData
import MapKit


//@CHANGED: added the @objc(), this makes it possible for the compiler to understand what we are trying to do here (core date still heavily depends on objective-c)
@objc(Pin)

class Pin: NSManagedObject{

// Insert code here to add functionality to your managed object subclass
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "listPhotos"
        static let Id = "id"
    }
    
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var listPhotos: [Photo]
   // @NSManaged var id : NSNumber
    
    // 4. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as? NSNumber
        
        longitude = dictionary[Keys.Longitude] as? NSNumber
        
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as! Double, longitude: longitude as! Double)
    }
}
